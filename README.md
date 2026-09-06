<p align="center"><strong>日本語</strong> · <a href="./README.ko.md">한국어</a> · <a href="./README.en.md">English</a></p>

<div align="center">
  <img src="./docs/media/teardrop-apollo.gif" alt="涙シェーダーの使用例" width="768">
  <h1>Hinasaki Shaders</h1>
</div>

<p align="center"><sub>涙シェーダーの使用例 · <a href="https://x.com/mbM0001_/status/1645361384719540226">元の投稿 — @mbM0001_</a></sub></p>

[@mbM0001_](https://x.com/mbM0001_) の依頼で制作した、Unity向け特殊効果シェーダー集です。涙・水滴の表現を中心に、モザイクやホログラフィックサイトを収録しています。

<p align="center"><sub>Unity · Built-in Render Pipeline · ShaderLab / Cg/HLSL</sub></p>

## 主な実装

| 機能 | 実装内容 |
|---|---|
| [涙・水滴](Assets/HinasakiShaders/Runtime/Tears) | UVアニメーションとマスクで流れや溜まりを描き、GrabPassで背景を屈折。Apollo版は目元の揺らめきを追加。 |
| [モザイク](Assets/HinasakiShaders/Runtime/Mosaic) | 画面UVを一定間隔に丸め、背景をピクセル化。 |
| [ホログラフィックサイト](Assets/HinasakiShaders/Runtime/HolographicSight) | 接線空間の視線方向からレティクルの位置を補正。 |
| [実験的な実装](Assets/HinasakiShaders/Experimental) | 迷彩・氷・旧サイトの試作と、テスト用アセット。 |

<details>
<summary><strong>調整画面とUVプレビューを見る</strong></summary>

### マテリアルの調整

![マテリアルの調整](docs/media/teardrop-controls.gif)

[元の投稿 — hjcud](https://x.com/i/status/1645361618661052416)

### 2D UVプレビュー

![2D UVプレビュー](docs/media/teardrop-uv-preview.gif)

[元の投稿 — hjcud](https://x.com/i/status/1645361804070232065)

</details>

## 使い方

1. `Assets/HinasakiShaders` と `Assets/HinasakiShaders.meta` を、使用するUnityプロジェクトの `Assets` にコピーします。
2. 各機能の `Materials` にあるマテリアルを対象メッシュに設定します。
3. 涙の位置・マスク・速度などを、メッシュのUVに合わせて調整します。

元の開発環境は **Unity 2019.4.31f1 / Built-in Render Pipeline** です。GrabPassを使用するため、URP/HDRPではそのまま動作しません。新しいUnityバージョンでの描画は未検証です。

シェーダー、マテリアル、テクスチャ、実験用モデルを収録しています。デモのアバター、シーン、外部SDKは含まれていません。

[シェーダー一覧・既知の制限](Assets/HinasakiShaders/README.md)

## 制作

| 担当 | クレジット |
|---|---|
| 依頼 | [@mbM0001_](https://x.com/mbM0001_) |
| シェーダー開発 | [hjcud](https://github.com/hjcud) |

## ライセンス

コードは [Apache-2.0](LICENSE) で公開しています。制作クレジットは [NOTICE](NOTICE) に記載しています。デモ映像・GIFと映像内のアバターは、このソフトウェアライセンスの対象外です。詳細は[メディアの出典](docs/media/README.md)をご覧ください。
