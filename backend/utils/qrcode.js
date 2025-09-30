const QRCode = require('qrcode');

exports.generateQRCode = async (data) => {
  try {
    const qr = await QRCode.toDataURL(JSON.stringify(data));
    return qr; // image base64
  } catch (err) {
    throw err;
  }
};
