from tools.generate_docker_image_names import generate_docker_image_names


def test_generate_docker_image_names_latest() -> None:
    """generate_docker_image_names() でデフォルトブランチ（latest）のDockerイメージ名を生成できることを確認する。"""

    # Expects
    expected_image_names = [
        "voicevox/voicevox_engine:latest",
        "voicevox/voicevox_engine:cpu-latest",
        "voicevox/voicevox_engine:cpu-ubuntu22.04-latest",
    ]

    # Outputs
    actual_image_names = generate_docker_image_names(
        "voicevox/voicevox_engine",
        "latest",
        ",cpu,cpu-ubuntu22.04",
    )

    # Test
    assert expected_image_names == actual_image_names


def test_generate_docker_image_names_release() -> None:
    """generate_docker_image_names() でリリースのDockerイメージ名を生成できることを確認する。"""

    # Expects
    expected_image_names = [
        "voicevox/voicevox_engine:0.22.0",
        "voicevox/voicevox_engine:cpu-0.22.0",
        "voicevox/voicevox_engine:cpu-ubuntu22.04-0.22.0",
    ]

    # Outputs
    actual_image_names = generate_docker_image_names(
        "voicevox/voicevox_engine",
        "0.22.0",
        ",cpu,cpu-ubuntu22.04",
    )

    # Test
    assert expected_image_names == actual_image_names
