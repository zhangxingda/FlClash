package com.follow.clash.plugins

import android.content.Context
import android.os.Build
import android.util.AtomicFile
import java.io.File
import java.util.UUID

object SubscriptionDeviceInfo {
    @Synchronized
    fun read(context: Context): Map<String, String> {
        val file = AtomicFile(File(context.noBackupFilesDir, "subscription-device-id"))
        val saved = runCatching {
            UUID.fromString(String(file.readFully(), Charsets.UTF_8)).toString()
        }.getOrNull()
        val id = saved ?: UUID.randomUUID().toString().also { generated ->
            val stream = file.startWrite()
            try {
                stream.write(generated.toByteArray(Charsets.UTF_8))
                file.finishWrite(stream)
            } catch (error: Exception) {
                file.failWrite(stream)
                throw error
            }
        }
        return mapOf(
            "device_id" to id,
            "device_brand" to Build.MANUFACTURER,
            "device_model" to Build.MODEL,
        )
    }
}
