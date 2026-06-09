# AR Flutter — R&D project

A Flutter demo app exploring AR (Augmented Reality) capabilities on iOS and Android with a unified Dart-side API.

## What's done

The main menu (`ARExamplesScreen`) has 4 entries — these are the AR scenarios we wanted to explore:

| Scenario | Status | Description |
|---|---|---|
| **Plane Detection** | ✅ Implemented | Detects horizontal and vertical planes in the real world. The user can place a 3D chair model on a detected surface (seat + back + 4 legs, built from primitives), remove it, or reset the AR session. |
| **Face Mask AR** | 🚧 Stub | Placeholder screen for virtual face masks and filters. |
| **Virtual Ring** | 🚧 Stub | Placeholder screen for virtual ring try-on (hand tracking). |
| **Body Tracking** | 🚧 Stub | Placeholder screen for body pose tracking. |

Only **Plane Detection** is actually wired up — it's the scenario we used to nail down the Flutter ↔ native AR bridge.

## How it works

### Architecture

Clean Architecture with layered separation:

```
lib/
├── core/
│   ├── di/                  # GetIt service locator
│   └── services/            # ARPlatformService (abstraction)
│       ├── arkit_platform_service.dart    # iOS impl
│       └── arcore_platform_service.dart   # Android impl
├── features/ar/
│   ├── data/repositories/   # ARRepositoryImpl
│   ├── domain/              # Entities + Repository contract
│   └── presentation/
│       ├── cubit/           # PlaneDetectionCubit + State
│       ├── screens/         # PlaneDetectionScreen
│       └── widgets/         # UnifiedARView, ARControls
└── screens/                 # Menu and stub screens
```

### Native ↔ Flutter bridge

`UnifiedARPlatformService` picks the platform at runtime and delegates calls to the matching native service:

- **iOS** — [ARKitViewController.swift](ios/Runner/ARKitViewController.swift): `ARSCNView` + `ARWorldTrackingConfiguration` with `planeDetection: [.horizontal, .vertical]`. The 3D chair is built from `SCNBox` / `SCNCylinder` primitives via `SceneKit`. Placement uses `hitTest(.existingPlaneUsingExtent)`.
- **Android** — [ARCoreViewController.kt](android/app/src/main/kotlin/com/example/ar_flutter/ARCoreViewController.kt): `ArSceneView` with `Sceneform`. The chair is built from `ShapeFactory.makeCube` / `makeCylinder` with `MaterialFactory`. Placement uses `frame.hitTest()` at screen center.

Communication runs over a `MethodChannel` named `arkit_flutter_plugin/{viewId}` (iOS) and `arcore_flutter_plugin/{viewId}` (Android). Calls into native: `addChairModel`, `removeChairModel`, `resetSession`. Callbacks back: `onChairPlaced`, `onChairRemoved`, `onPlaneDetected`, `onError`.

On the Flutter side the native AR viewport is embedded via `UiKitView` / `AndroidView` inside `UnifiedARView`.

### State management

`PlaneDetectionCubit` (flutter_bloc) holds the AR session state (`Loading`, `Ready`, `ChairPlaced`, `Error`) and listens to the event stream from the native service. UI reacts via `BlocBuilder`.

## Tech stack

- **Flutter** (Dart SDK ^3.7.2)
- **iOS:** ARKit + SceneKit (native, no third-party plugins)
- **Android:** ARCore + Sceneform
- **Architecture:** Clean Architecture, BLoC/Cubit pattern
- **Packages:**
  - `flutter_bloc` — state management
  - `get_it` — dependency injection
  - `go_router` — navigation
  - `freezed` + `json_serializable` — code generation
  - `equatable` — value equality

## Problems we hit and how we solved them

1. **One API on top of two very different AR stacks.** ARKit (iOS) and ARCore + Sceneform (Android) have completely different object models and lifecycles. Solution — an `ARPlatformService` interface plus `UnifiedARPlatformService` that swaps the implementation based on `Platform.isIOS / isAndroid`. The UI talks to a single contract.

2. **Crashes on OPPO and old Android with HDR lighting.** `Config.LightEstimationMode.ENVIRONMENTAL_HDR` was unstable on OPPO and Android < 11. Solution — `getSafeLightEstimationMode()` in [ARCoreViewController.kt:140](android/app/src/main/kotlin/com/example/ar_flutter/ARCoreViewController.kt:140), which returns `AMBIENT_INTENSITY` for OPPO / Android < 11 and only tries `ENVIRONMENTAL_HDR` on newer devices from other vendors.

3. **Placing a model before any plane is detected.** If the user taps "Place chair" before ARCore/ARKit has had time to detect a plane, the hit test returns empty. Fallback — place the chair ~1 m in front of the camera (`placeChairInFrontOfCamera()` on Android, a similar `camera.transform` branch on iOS).

4. **Native `ArSceneView` lifecycle.** Sceneform requires the session to be created after the `View` is attached to the hierarchy. Solution — deferred `setupAR()` via `sceneView.post { ... }` in `getView()`.

5. **Session cleanup.** `resetSession` fully restarts the AR config, removes all anchors and the placed model — otherwise old plane "ghosts" stuck around after reset.

## Running

```bash
flutter pub get
flutter run
```

Requirements:
- iOS: ARKit-capable device (iPhone 6s+), iOS 11+, camera permission in `Info.plist`.
- Android: device from the [ARCore supported devices](https://developers.google.com/ar/devices) list, Google Play Services for AR installed, `CAMERA` permission.

## Screens

- `/ar-examples` — menu
- `/plane-detection` — working AR screen
- `/face-mask`, `/ring-try-on`, `/body-tracking` — stubs for future scenarios

## Next up

Implement the remaining three scenarios (face mask, ring try-on, body tracking). On iOS this needs `ARFaceTrackingConfiguration` / `ARBodyTrackingConfiguration`; on Android — ARCore Augmented Faces and/or ML Kit Pose Detection (ARCore has no first-class body tracking).
