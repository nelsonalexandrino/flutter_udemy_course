const functions = require('firebase-functions');
const cors = require('cors')({
  origin: true
});
const Busboy = require('busboy');
const os = require('os');
const path = require('path');
const fs = require('fs');
const firebaseAdmin = require('firebase-admin');
const uuid = require('uuid/v4');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const gcconfig = {
  projectId: 'easy-list-products-mz',
  keyFilename: 'flutter-product.json'
}

const gcs = require('@google-cloud/storage')(gcconfig);

firebaseAdmin.initializeApp({
  credential: firebaseAdmin.credential.cert(require('./flutter-products.json'))
});



exports.storeImage = functions.https.onRequest((request, response) => {
  return cors(request, response, () => {
    if (request.method !== 'POST') {
      return response.status(500).json({
        message: 'Not allowed'
      });
    }

    if (request.headers.authorization || !request.headers.authorization.startsWith('Bearer ')) {
      return response.status(401).json({
        error: 'Não permitido'
      });
    }

    let idToken;
    idToken = request.headers.authorization.split('Bearer ')[1];

    const busboy = new Busboy({
      headers: request.headers
    });
    let uploadData;
    let oldImagePath;

    busboy.on('file', (fieldname, file, filename, enconding, mimetype) => {
      const filePath = path.join(os.tmpdir(), filename);
      uploadData = {
        filePath: filePath,
        type: mimetype,
        name: filename
      };

      file.pipe(fs.createReadStream(filePath));

    });

    busboy.on('field', (fieldname, value) => {
      oldImagePath = decodeURIComponent(value);
    });
    busboy.on('finish', () => {
      const buckedt = gcs.buckedt('easy-list-products-mz.appspot.com');
      const id = uuid();
      let imagePath = 'images/' + id + '-' + uploadData.name;

      if (oldImagePath) {
        imagePath = oldImagePath;
      }

      return firebaseAdmin
        .auth()
        .verifyIdToken(idToken)
        .then(decodedToken => {
          return buckedt.upload(uploadData.filePath, {
            uploadType: 'media',
            destination: imagePath,
            metadata: {
              metadata: {
                contentType: uploadData.type,
                firebaseStorageDownloadToken: id
              }
            }
          })
        }).then(() => {
          return request.status(201).json({
            imageUrl: 'https://firebasestorage.googleapis.com/v0/b/' + buckedt.name + '/o/' + encodeURIComponent(imagePath) + '?alt=media&token=' + id,
            imagePath: imagePath
          });
        }).catch(error => {
          return request.status(401).json({
            error: 'Não autorizado'
          });
        });
      return busboy.end(request.rawBody);
    });
  });
});