package com.stromx.stromx_ide

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val channelName = "com.stromx.ide/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "runCommand" -> {
                    val command = call.argument<String>("command")?.trim().orEmpty()
                    if (command.isBlank()) { result.success(""); return@setMethodCallHandler }
                    try {
                        val process = ProcessBuilder("/system/bin/sh", "-c", command)
                            .directory(filesDir)
                            .redirectErrorStream(true)
                            .start()
                        val finished = process.waitFor(8, TimeUnit.SECONDS)
                        if (!finished) {
                            process.destroyForcibly()
                            result.success("Command timed out after 8 seconds")
                        } else {
                            val text = process.inputStream.bufferedReader().use { it.readText() }
                            result.success(text.ifBlank { "Exit code: ${process.exitValue()}" })
                        }
                    } catch (e: Exception) { result.error("SHELL_ERROR", e.message, null) }
                }
                "saveFile" -> {
                    try {
                        val name = call.argument<String>("name") ?: "main.txt"
                        val safeName = File(name).name
                        val content = call.argument<String>("content") ?: ""
                        val workspace = File(filesDir, "workspace").apply { mkdirs() }
                        val target = File(workspace, safeName)
                        target.writeText(content)
                        result.success(target.absolutePath)
                    } catch (e: Exception) { result.error("SAVE_ERROR", e.message, null) }
                }
                else -> result.notImplemented()
            }
        }
    }
}
