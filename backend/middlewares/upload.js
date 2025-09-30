const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: 'uploads/', // dossier où les images seront stockées
  filename: (req, file, cb) => {
    const uniqueName = Date.now() + path.extname(file.originalname);
    cb(null, uniqueName);
  },
});

module.exports = multer({ storage });
