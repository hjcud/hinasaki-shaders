<p align="center"><a href="./README.md">日本語</a> · <strong>한국어</strong> · <a href="./README.en.md">English</a></p>

<div align="center">
  <img src="./docs/media/teardrop-apollo.gif" alt="눈물 셰이더 적용 예시" width="768">
  <h1>Hinasaki Shaders</h1>
</div>

<p align="center"><sub>눈물 셰이더 적용 예시 · <a href="https://x.com/mbM0001_/status/1645361384719540226">원본 게시물 — @mbM0001_</a></sub></p>

[@mbM0001_](https://x.com/mbM0001_)님의 의뢰로 제작한 Unity 특수효과 셰이더 모음입니다. 눈물과 물방울 표현을 중심으로 모자이크와 홀로그래픽 조준경을 포함합니다.

<p align="center"><sub>Unity · Built-in Render Pipeline · ShaderLab / Cg/HLSL</sub></p>

## 주요 구현

| 기능 | 구현 내용 |
|---|---|
| [눈물·물방울](Assets/HinasakiShaders/Runtime/Tears) | UV 애니메이션과 마스크로 흐름과 맺힘을 표현하고 GrabPass로 배경을 굴절시킵니다. Apollo 버전은 눈가의 일렁임을 추가합니다. |
| [모자이크](Assets/HinasakiShaders/Runtime/Mosaic) | 화면 UV를 일정 간격으로 양자화해 배경을 픽셀화합니다. |
| [홀로그래픽 조준경](Assets/HinasakiShaders/Runtime/HolographicSight) | 접선 공간의 시선 방향으로 조준점 위치를 보정합니다. |
| [실험 구현](Assets/HinasakiShaders/Experimental) | 위장·얼음·초기 조준경 프로토타입과 테스트 에셋입니다. |

<details>
<summary><strong>조절 화면과 UV 미리보기 보기</strong></summary>

### 머티리얼 조절

![머티리얼 조절](docs/media/teardrop-controls.gif)

[원본 게시물 — hjcud](https://x.com/i/status/1645361618661052416)

### 2D UV 미리보기

![2D UV 미리보기](docs/media/teardrop-uv-preview.gif)

[원본 게시물 — hjcud](https://x.com/i/status/1645361804070232065)

</details>

## 사용 방법

1. `Assets/HinasakiShaders`와 `Assets/HinasakiShaders.meta`를 사용할 Unity 프로젝트의 `Assets`로 복사합니다.
2. 각 기능의 `Materials` 폴더에 있는 머티리얼을 대상 메시에 적용합니다.
3. 눈물 위치·마스크·속도 등을 메시의 UV에 맞게 조절합니다.

원래 개발 환경은 **Unity 2019.4.31f1 / Built-in Render Pipeline**입니다. GrabPass를 사용하므로 URP/HDRP에서 그대로 사용할 수 없습니다. 최신 Unity 버전의 렌더링 호환성은 검증하지 않았습니다.

셰이더, 머티리얼, 텍스처, 실험용 모델을 포함합니다. 데모의 아바타, 씬, 외부 SDK는 포함하지 않습니다.

[셰이더 목록과 알려진 제한 사항](Assets/HinasakiShaders/README.md)

## 제작

| 역할 | 크레딧 |
|---|---|
| 의뢰 | [@mbM0001_](https://x.com/mbM0001_) |
| 셰이더 개발 | [hjcud](https://github.com/hjcud) |

## 라이선스

코드는 [Apache-2.0](LICENSE)으로 공개합니다. 제작 크레딧은 [NOTICE](NOTICE)에 기록되어 있습니다. 데모 영상·GIF와 영상 속 아바타는 이 소프트웨어 라이선스의 대상이 아닙니다. 자세한 출처는 [미디어 문서](docs/media/README.md)를 참고하세요.
