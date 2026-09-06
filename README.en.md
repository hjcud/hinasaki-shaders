<p align="center"><a href="./README.md">日本語</a> · <a href="./README.ko.md">한국어</a> · <strong>English</strong></p>

<div align="center">
  <img src="./docs/media/teardrop-apollo.gif" alt="Tear shader demonstration" width="768">
  <h1>Hinasaki Shaders</h1>
</div>

<p align="center"><sub>Tear shader demonstration · <a href="https://x.com/mbM0001_/status/1645361384719540226">Original post — @mbM0001_</a></sub></p>

A collection of Unity visual-effect shaders developed as commissioned work for [@mbM0001_](https://x.com/mbM0001_). It focuses on tears and water droplets, with mosaic and holographic sight effects alongside them.

<p align="center"><sub>Unity · Built-in Render Pipeline · ShaderLab / Cg/HLSL</sub></p>

## Main implementations

| Feature | Implementation |
|---|---|
| [Tears and droplets](Assets/HinasakiShaders/Runtime/Tears) | UV animation and masks shape flowing and pooled tears; GrabPass refracts the background. The Apollo variant adds shimmer around the eyes. |
| [Mosaic](Assets/HinasakiShaders/Runtime/Mosaic) | Quantized screen UVs pixelate the background. |
| [Holographic sight](Assets/HinasakiShaders/Runtime/HolographicSight) | Tangent-space view direction offsets the reticle. |
| [Experiments](Assets/HinasakiShaders/Experimental) | Camouflage, ice, and earlier sight prototypes, with test assets. |

<details>
<summary><strong>View material controls and UV preview</strong></summary>

### Material controls

![Material controls](docs/media/teardrop-controls.gif)

[Original post — hjcud](https://x.com/i/status/1645361618661052416)

### 2D UV preview

![2D UV preview](docs/media/teardrop-uv-preview.gif)

[Original post — hjcud](https://x.com/i/status/1645361804070232065)

</details>

## Usage

[Download the Unity package — v0.1.0 prerelease](https://github.com/hjcud/hinasaki-shaders/releases/tag/v0.1.0)

Import the `.unitypackage` through Unity’s **Assets → Import Package → Custom Package…** menu. To install from source, follow the steps below.

1. Copy `Assets/HinasakiShaders` and `Assets/HinasakiShaders.meta` into your Unity project’s `Assets` directory.
2. Apply a material from the corresponding feature’s `Materials` folder to your mesh.
3. Adjust tear positions, masks, speeds, and other parameters to suit the mesh’s UV layout.

Originally developed with **Unity 2019.4.31f1 / Built-in Render Pipeline**. The GrabPass effects require adaptation for URP/HDRP. Rendering compatibility with newer Unity versions has not been verified.

Includes shaders, materials, textures, and experimental models. The avatars shown in the demos, scenes, and external SDKs are not included.

[Shader list and known limitations](Assets/HinasakiShaders/README.md)

## Credits

| Role | Credit |
|---|---|
| Commissioned by | [@mbM0001_](https://x.com/mbM0001_) |
| Shader development | [hjcud](https://github.com/hjcud) |

## License

Code is published under [Apache-2.0](LICENSE). Project credits are recorded in [NOTICE](NOTICE). Demo footage, GIFs, and the depicted avatars are excluded from this software license. See the [media documentation](docs/media/README.md) for sources and details.
