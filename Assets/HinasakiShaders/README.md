# Hinasaki Shaders — asset guide

Developed by [hjcud](https://github.com/hjcud) as commissioned work for [@mbM0001_](https://x.com/mbM0001_).

## Layout and usage

`Runtime` contains the tears, mosaic, and holographic sight shaders with their material presets and textures. `Experimental` contains camouflage, ice, and earlier sight implementations, additional textures, and three test models.

Copy the entire `HinasakiShaders` folder with its `.meta` files into your project's `Assets` directory. Apply a supplied material to your mesh, then adjust its parameters for that mesh's UVs. Keep both Runtime and Experimental when using the supplied experimental presets: Ice shares a Camouflage noise texture, and the earlier sight shares Runtime textures. Demo avatars, scenes, animation controllers, and external SDKs are not included.

Originally developed with **Unity 2019.4.31f1 / Built-in Render Pipeline**. GrabPass-based effects require adaptation for URP/HDRP. The folder names do not imply a tested compatibility or stability tier.

## Shader selection names

The original ShaderLab names and asset GUIDs are preserved.

| File | Unity shader selection |
|---|---|
| [Teardrop](Runtime/Tears/Shaders/Teardrop.shader) | `Hinasaki/Teardrop` |
| [TeardropApollo](Runtime/Tears/Shaders/TeardropApollo.shader) | `Hinasaki/Teardrop_APOLLO` |
| [Waterdrop](Runtime/Tears/Shaders/Waterdrop.shader) | `Hinasaki/Waterdrop` |
| [Mosaic](Runtime/Mosaic/Shaders/Mosaic.shader) | `Hinasaki/Mosaic` |
| [HoloSight](Runtime/HolographicSight/Shaders/HoloSight.shader) | `Hinasaki/HoloSight` |
| [CamouflageLegacy](Experimental/Camouflage/Shaders/CamouflageLegacy.shader) | `Hinasaki/Camouflage` |
| [CamouflageTransition](Experimental/Camouflage/Shaders/CamouflageTransition.shader) | `Hinasaki/Camouflage_v2` |
| [RandomCellColors](Experimental/Camouflage/Shaders/RandomCellColors.shader) | `Hinasaki/Camouflage_v3` |
| [IceDistortion](Experimental/Ice/Shaders/IceDistortion.shader) | `Yoiko/Ice` |
| [IceSurfaceReference](Experimental/Ice/Shaders/IceSurfaceReference.shader) | `Yoiko/Ice_2` |
| [HolographicSightLegacy](Experimental/HolographicSight/Shaders/HolographicSightLegacy.shader) | `Hinasaki/HolographicSight` |

## Distribution presets

Shader behavior and import settings are unchanged. For a self-contained distribution, unused `_NoiseTex` entries pointing to missing textures were removed from Teardrop, TeardropApollo, and HoloSight materials. Two experimental presets use bundled textures: CamouflageTransition uses HexagonPattern, and HolographicSightLegacyAlternate uses HolographicReticle. These two presets may look different from the original development setup.

## Known limitations

- Waterdrop computes animated noise UVs but samples the original UV; Noise Speed has no effect.
- CamouflageLegacy outputs black in its non-refracting branch. Texture Power is ineffective in both camouflage variants.
- RandomCellColors generates square random-color cells, not hexagons.
- Experimental ice implementations retain coordinate-space and unused-property issues.
- Existing fallback-name typos and other legacy shader behavior are preserved.
- Unity compilation, newer Unity versions, VR stereo rendering, mirrors, and GPU performance have not been revalidated for this distribution.
