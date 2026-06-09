package com.example.ar_flutter

import android.content.Context
import android.view.View
import android.os.Build
import com.google.ar.core.*
import com.google.ar.core.exceptions.*
import com.google.ar.sceneform.AnchorNode
import com.google.ar.sceneform.ArSceneView
import com.google.ar.sceneform.FrameTime
import com.google.ar.sceneform.Scene
import com.google.ar.sceneform.Node
import com.google.ar.sceneform.math.Vector3
import com.google.ar.sceneform.rendering.MaterialFactory
import com.google.ar.sceneform.rendering.ShapeFactory
import com.google.ar.sceneform.rendering.Color
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class ARCoreViewController(
    private val context: Context,
    private val viewId: Int,
    messenger: BinaryMessenger
) : PlatformView, Scene.OnUpdateListener {

    private val channel = MethodChannel(messenger, "arcore_flutter_plugin/$viewId")
    private val sceneView: ArSceneView = ArSceneView(context)
    private var chairNode: AnchorNode? = null
    private var currentAnchor: Anchor? = null
    private var installRequested = false

    init {
        println("🟢 ARCoreViewController init started")
        setupMethodChannel()
    }

    override fun getView(): View {
        println("🟢 ARCoreViewController.getView() called")

        // Налаштовуємо AR тільки коли view готовий
        sceneView.post {
            println("🟢 SceneView is ready, setting up AR")
            setupAR()
        }

        return sceneView
    }

    private fun setupAR() {
        try {
            println("🟢 Setting up ARCore...")

            // ВИПРАВЛЕНО: Не робимо cast до Activity, а передаємо context напряму
            when (ArCoreApk.getInstance().checkAvailability(context)) {
                ArCoreApk.Availability.SUPPORTED_INSTALLED -> {
                    println("✅ ARCore is installed")
                }
                ArCoreApk.Availability.SUPPORTED_APK_TOO_OLD -> {
                    println("⚠️ ARCore APK too old")
                    channel.invokeMethod("onError", mapOf("message" to "ARCore APK needs update"))
                    return
                }
                ArCoreApk.Availability.SUPPORTED_NOT_INSTALLED -> {
                    println("⚠️ ARCore not installed")
                    channel.invokeMethod("onError", mapOf("message" to "ARCore not installed"))
                    return
                }
                ArCoreApk.Availability.UNSUPPORTED_DEVICE_NOT_CAPABLE -> {
                    println("🔴 Device not capable")
                    channel.invokeMethod("onError", mapOf("message" to "Device not capable of AR"))
                    return
                }
                else -> {
                    println("🔴 ARCore availability unknown")
                    channel.invokeMethod("onError", mapOf("message" to "ARCore availability unknown"))
                    return
                }
            }

            // Створюємо сесію ARCore
            println("🟢 Creating ARCore session...")
            val session = Session(context)

            // Налаштовуємо конфігурацію з безпечним режимом освітлення
            println("🟢 Configuring ARCore session...")
            val config = Config(session).apply {
                planeFindingMode = Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL
                updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
                // ВИПРАВЛЕННЯ: Використовуємо безпечний режим освітлення для OPPO
                lightEstimationMode = getSafeLightEstimationMode()
            }

            // Застосовуємо конфігурацію
            session.configure(config)
            println("✅ ARCore session configured with light mode: ${config.lightEstimationMode}")

            // КРИТИЧНО: Встановлюємо сесію до SceneView
            println("🟢 Setting up SceneView session...")
            sceneView.setupSession(session)
            println("✅ SceneView session setup complete")

            // Розпочинаємо сесію
            println("🟢 Resuming SceneView...")
            sceneView.resume()
            println("✅ SceneView resumed")

            // Додаємо listener для оновлень
            sceneView.scene.addOnUpdateListener(this)
            println("✅ OnUpdateListener added")

            println("🎉 ARCore setup completed successfully")
            channel.invokeMethod("onArCoreReady", null)

        } catch (e: SecurityException) {
            println("🔴 Camera permission denied: ${e.message}")
            channel.invokeMethod("onError", mapOf("message" to "Camera permission denied"))
        } catch (e: UnavailableArcoreNotInstalledException) {
            println("🔴 ARCore not installed: ${e.message}")
            channel.invokeMethod("onError", mapOf("message" to "ARCore not installed"))
        } catch (e: UnavailableUserDeclinedInstallationException) {
            println("🔴 User declined ARCore installation: ${e.message}")
            channel.invokeMethod("onError", mapOf("message" to "ARCore installation declined"))
        } catch (e: UnavailableSdkTooOldException) {
            println("🔴 ARCore SDK too old: ${e.message}")
            channel.invokeMethod("onError", mapOf("message" to "ARCore SDK too old"))
        } catch (e: UnavailableDeviceNotCompatibleException) {
            println("🔴 Device not compatible: ${e.message}")
            channel.invokeMethod("onError", mapOf("message" to "Device not compatible with ARCore"))
        } catch (e: CameraNotAvailableException) {
            println("🔴 Camera not available: ${e.message}")
            channel.invokeMethod("onError", mapOf("message" to "Camera not available"))
        } catch (e: Exception) {
            println("🔴 Error setting up ARCore: ${e.message}")
            e.printStackTrace()
            channel.invokeMethod("onError", mapOf("message" to "ARCore setup failed: ${e.message}"))
        }
    }

    private fun getSafeLightEstimationMode(): Config.LightEstimationMode {
        val manufacturer = Build.MANUFACTURER.lowercase()

        return when {
            manufacturer.contains("oppo") -> {
                println("🟡 OPPO device detected, using AMBIENT_INTENSITY lighting")
                Config.LightEstimationMode.AMBIENT_INTENSITY
            }
            Build.VERSION.SDK_INT < Build.VERSION_CODES.R -> {
                println("🟡 Android < 11 detected, using AMBIENT_INTENSITY lighting")
                Config.LightEstimationMode.AMBIENT_INTENSITY
            }
            else -> {
                try {
                    println("🟢 Attempting HDR lighting for compatible device")
                    Config.LightEstimationMode.ENVIRONMENTAL_HDR
                } catch (e: Exception) {
                    println("🟡 HDR not supported, falling back to AMBIENT_INTENSITY")
                    Config.LightEstimationMode.AMBIENT_INTENSITY
                }
            }
        }
    }

    /**
     * АЛЬТЕРНАТИВНИЙ МЕТОД: Перевірка через рефлексію
     * Можна використати замість getSafeLightEstimationMode()
     */
    private fun isHdrLightingSupported(): Boolean {
        return try {
            // Перевіряємо чи існує метод acquireEnvironmentalHdrCubeMap
            LightEstimate::class.java.getMethod("acquireEnvironmentalHdrCubeMap")
            println("✅ HDR lighting supported")
            true
        } catch (e: NoSuchMethodException) {
            println("⚠️ HDR lighting not supported: ${e.message}")
            false
        }
    }

    private fun setupMethodChannel() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "addChairModel" -> {
                    println("🟢 Add chair model requested")
                    addChairModel()
                    result.success(null)
                }
                "removeChairModel" -> {
                    println("🟢 Remove chair model requested")
                    removeChairModel()
                    result.success(null)
                }
                "resetSession" -> {
                    println("🟢 Reset session requested")
                    resetSession()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onUpdate(frameTime: FrameTime) {
        val frame = sceneView.arFrame
        if (frame == null) {
            // println("⚠️ No AR frame in onUpdate")
            return
        }

        try {
            val updatedTrackables = frame.getUpdatedTrackables(Plane::class.java)

            for (trackable in updatedTrackables) {
                if (trackable.trackingState == TrackingState.TRACKING) {
                    val plane = trackable as Plane
                    if (plane.type == Plane.Type.HORIZONTAL_UPWARD_FACING) {
                        // Plane detected, notify Flutter (тільки раз)
                        // println("✅ Horizontal plane detected")
                        channel.invokeMethod("onPlaneDetected", null)
                    }
                }
            }
        } catch (e: Exception) {
            println("🔴 Error in onUpdate: ${e.message}")
        }
    }

    private fun addChairModel() {
        try {
            println("🟢 Adding chair model...")
            val frame = sceneView.arFrame
            if (frame == null) {
                println("⚠️ No AR frame available")
                placeChairInFrontOfCamera()
                return
            }

            val hitResult = performHitTest(frame)
            hitResult?.let { result ->
                println("✅ Hit test successful, creating anchor")
                val anchor = result.createAnchor()
                currentAnchor = anchor
                createChairModel(anchor)
                channel.invokeMethod("onChairPlaced", null)
            } ?: run {
                println("⚠️ No hit test result, placing chair in front of camera")
                placeChairInFrontOfCamera()
            }
        } catch (e: Exception) {
            println("🔴 Error adding chair model: ${e.message}")
            channel.invokeMethod("onError", mapOf("message" to "Failed to place chair: ${e.message}"))
        }
    }

    private fun performHitTest(frame: Frame): HitResult? {
        val screenCenterX = sceneView.width / 2f
        val screenCenterY = sceneView.height / 2f
        println("🟢 Performing hit test at center: ($screenCenterX, $screenCenterY)")

        val hits = frame.hitTest(screenCenterX, screenCenterY)
        println("🟢 Hit test returned ${hits.size} results")

        for (hit in hits) {
            val trackable = hit.trackable
            if (trackable is Plane && trackable.type == Plane.Type.HORIZONTAL_UPWARD_FACING) {
                println("✅ Found horizontal plane hit")
                return hit
            }
        }
        println("⚠️ No suitable plane found in hit test")
        return null
    }

    private fun placeChairInFrontOfCamera() {
        try {
            println("🟢 Placing chair in front of camera...")
            val session = sceneView.session ?: run {
                println("🔴 No session available")
                return
            }
            val camera = sceneView.arFrame?.camera ?: run {
                println("🔴 No camera available")
                return
            }

            val cameraTransform = camera.pose
            val forwardTranslation = Pose.makeTranslation(0f, -0.3f, -1.0f)
            val chairPose = cameraTransform.compose(forwardTranslation)

            val anchor = session.createAnchor(chairPose)
            currentAnchor = anchor
            createChairModel(anchor)
            println("✅ Chair placed in front of camera")
            channel.invokeMethod("onChairPlaced", null)
        } catch (e: Exception) {
            println("🔴 Error placing chair in front of camera: ${e.message}")
        }
    }

    private fun createChairModel(anchor: Anchor) {
        println("🟢 Creating chair model...")
        val anchorNode = AnchorNode(anchor)
        anchorNode.setParent(sceneView.scene)
        chairNode = anchorNode

        // Create simple chair seat
        MaterialFactory.makeOpaqueWithColor(context, Color(android.graphics.Color.RED))
            .thenAccept { material ->
                println("🟢 Creating chair seat...")
                val seatRenderable = ShapeFactory.makeCube(
                    Vector3(0.4f, 0.05f, 0.4f),
                    Vector3(0f, 0.125f, 0f),
                    material
                )
                val seatNode = Node()
                seatNode.renderable = seatRenderable
                seatNode.setParent(anchorNode)
                println("✅ Chair seat created")
            }

        // Create chair back
        MaterialFactory.makeOpaqueWithColor(context, Color(android.graphics.Color.BLUE))
            .thenAccept { material ->
                println("🟢 Creating chair back...")
                val backRenderable = ShapeFactory.makeCube(
                    Vector3(0.4f, 0.3f, 0.05f),
                    Vector3(0f, 0.275f, -0.175f),
                    material
                )
                val backNode = Node()
                backNode.renderable = backRenderable
                backNode.setParent(anchorNode)
                println("✅ Chair back created")
            }

        // Create chair legs
        MaterialFactory.makeOpaqueWithColor(context, Color(android.graphics.Color.parseColor("#8B4513")))
            .thenAccept { material ->
                println("🟢 Creating chair legs...")
                val legPositions = listOf(
                    Vector3(0.15f, 0.125f, 0.15f),
                    Vector3(-0.15f, 0.125f, 0.15f),
                    Vector3(0.15f, 0.125f, -0.15f),
                    Vector3(-0.15f, 0.125f, -0.15f)
                )

                for (position in legPositions) {
                    val legRenderable = ShapeFactory.makeCylinder(
                        0.02f,
                        0.25f,
                        position,
                        material
                    )
                    val legNode = Node()
                    legNode.renderable = legRenderable
                    legNode.setParent(anchorNode)
                }
                println("✅ Chair legs created")
            }

        println("✅ Chair model creation completed")
    }

    private fun removeChairModel() {
        println("🟢 Removing chair model...")
        chairNode?.let {
            it.setParent(null)
            chairNode = null
        }
        currentAnchor?.detach()
        currentAnchor = null
        channel.invokeMethod("onChairRemoved", null)
        println("✅ Chair model removed")
    }

    private fun resetSession() {
        try {
            println("🟢 Resetting AR session...")
            removeChairModel()
            val session = sceneView.session
            session?.let {
                it.pause()
                val config = Config(it).apply {
                    planeFindingMode = Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL
                    updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
                    // Використовуємо той самий безпечний режим освітлення
                    lightEstimationMode = getSafeLightEstimationMode()
                }
                it.configure(config)
                it.resume()
            }
            println("✅ AR session reset completed")
        } catch (e: Exception) {
            println("🔴 Error resetting session: ${e.message}")
        }
    }

    override fun dispose() {
        try {
            println("🟢 Disposing ARCore view...")
            sceneView.scene.removeOnUpdateListener(this)
            sceneView.pause()
            sceneView.destroy()
            println("✅ ARCore view disposed")
        } catch (e: Exception) {
            println("🔴 Error disposing ARCore view: ${e.message}")
        }
    }
}