from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse

from voicevox_engine import __version__
from voicevox_engine.app.dependencies import deprecated_mutable_api
from voicevox_engine.app.middlewares import configure_middlewares
from voicevox_engine.app.openapi_schema import configure_openapi_schema
from voicevox_engine.app.routers.engine_info import generate_engine_info_router
from voicevox_engine.app.routers.library import generate_library_router
from voicevox_engine.app.routers.morphing import generate_morphing_router
from voicevox_engine.app.routers.preset import generate_preset_router
from voicevox_engine.app.routers.setting import generate_setting_router
from voicevox_engine.app.routers.speaker import generate_speaker_router
from voicevox_engine.app.routers.tts_pipeline import generate_tts_pipeline_router
from voicevox_engine.app.routers.user_dict import generate_user_dict_router
from voicevox_engine.cancellable_engine import CancellableEngine
from voicevox_engine.core.core_adapter import CoreAdapter
from voicevox_engine.engine_manifest.EngineManifestLoader import EngineManifestLoader
from voicevox_engine.library_manager import LibraryManager
from voicevox_engine.metas.MetasStore import MetasStore
from voicevox_engine.preset.PresetManager import PresetManager
from voicevox_engine.setting.Setting import CorsPolicyMode
from voicevox_engine.setting.SettingLoader import SettingHandler
from voicevox_engine.tts_pipeline.tts_engine import TTSEngine
from voicevox_engine.user_dict.user_dict import UserDictionary
from voicevox_engine.utility.path_utility import engine_root, get_save_dir


def generate_app(
    tts_engines: dict[str, TTSEngine],
    cores: dict[str, CoreAdapter],
    latest_core_version: str,
    setting_loader: SettingHandler,
    preset_manager: PresetManager,
    user_dict: UserDictionary,
    cancellable_engine: CancellableEngine | None = None,
    root_dir: Path | None = None,
    cors_policy_mode: CorsPolicyMode = CorsPolicyMode.localapps,
    allow_origin: list[str] | None = None,
    disable_mutable_api: bool = False,
) -> FastAPI:
    """ASGI 'application' 仕様に準拠した VOICEVOX ENGINE アプリケーションインスタンスを生成する。"""
    if root_dir is None:
        root_dir = engine_root()

    engine_manifest_data = EngineManifestLoader(
        engine_root() / "engine_manifest.json", engine_root()
    ).load_manifest()

    @asynccontextmanager
    async def lifespan(app: FastAPI) -> AsyncIterator[None]:
        user_dict.update_dict()
        yield

    app = FastAPI(
        title=engine_manifest_data.name,
        description=f"{engine_manifest_data.brand_name} の音声合成エンジンです。",
        version=__version__,
        lifespan=lifespan,
    )
    app = configure_middlewares(app, cors_policy_mode, allow_origin)

    if disable_mutable_api:
        deprecated_mutable_api.enable = False

    library_manager = LibraryManager(
        get_save_dir() / "installed_libraries",
        engine_manifest_data.supported_vvlib_manifest_version,
        engine_manifest_data.brand_name,
        engine_manifest_data.name,
        engine_manifest_data.uuid,
    )

    metas_store = MetasStore(root_dir / "speaker_info")

    def get_engine(core_version: str | None) -> TTSEngine:
        if core_version is None:
            return tts_engines[latest_core_version]
        if core_version in tts_engines:
            return tts_engines[core_version]
        raise HTTPException(status_code=422, detail="不明なバージョンです")

    def get_core(core_version: str | None) -> CoreAdapter:
        """指定したバージョンのコアを取得する"""
        if core_version is None:
            return cores[latest_core_version]
        if core_version in cores:
            return cores[core_version]
        raise HTTPException(status_code=422, detail="不明なバージョンです")

    app.include_router(
        generate_tts_pipeline_router(
            get_engine, get_core, preset_manager, cancellable_engine
        )
    )
    app.include_router(generate_morphing_router(get_engine, get_core, metas_store))
    app.include_router(generate_preset_router(preset_manager))
    app.include_router(generate_speaker_router(get_core, metas_store, root_dir))
    if engine_manifest_data.supported_features.manage_library:
        app.include_router(
            generate_library_router(engine_manifest_data, library_manager)
        )
    app.include_router(generate_user_dict_router(user_dict))
    app.include_router(
        generate_engine_info_router(get_core, cores, engine_manifest_data)
    )
    app.include_router(generate_setting_router(setting_loader, engine_manifest_data))

    @app.get("/", response_class=HTMLResponse, tags=["その他"])
    async def get_portal() -> str:
        """ポータルページを返します。"""
        engine_name = engine_manifest_data.name

        return f"""
        <html>
            <head>
                <title>{engine_name}</title>
            </head>
            <body>
                <h1>{engine_name}</h1>
                {engine_name} へようこそ！
                <ul>
                    <li><a href='/setting'>設定</a></li>
                    <li><a href='/docs'>API ドキュメント</a></li>
        </ul></body></html>
        """

    app = configure_openapi_schema(app)

    return app
