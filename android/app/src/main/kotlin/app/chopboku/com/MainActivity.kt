package app.chopboku.com

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import androidx.core.view.WindowCompat   // 👈 Add this import

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ✅ This enables edge-to-edge without needing ComponentActivity
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
