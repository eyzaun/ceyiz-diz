// Firebase Cloud Function - Batch Resize
// Bu dosyayı firebase/functions/index.js içine ekleyin

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const path = require('path');
const { spawn } = require('child-process-promise');

// Tüm eski fotoğrafları resize etmek için çalıştırın
exports.batchResizeImages = functions.https.onRequest(async (req, res) => {
  try {
    const bucket = admin.storage().bucket();
    const [files] = await bucket.getFiles({
      prefix: 'trousseaus/'
    });

    let processed = 0;
    let errors = 0;

    for (const file of files) {
      // Sadece .jpg ve .jpeg dosyalarını işle
      if (!file.name.match(/\.(jpg|jpeg)$/i)) continue;
      
      // Zaten thumbnail ise atla
      if (file.name.includes('_thumb@')) continue;

      try {
        // Resize Images extension'ı tetikle
        // Extension otomatik olarak dosyayı işleyecek
        await file.setMetadata({
          metadata: {
            resizedAt: Date.now().toString()
          }
        });
        
        processed++;
      } catch (err) {
        console.error(`Error processing ${file.name}:`, err);
        errors++;
      }
    }

    res.json({
      success: true,
      processed,
      errors,
      message: `Processed ${processed} images, ${errors} errors`
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
