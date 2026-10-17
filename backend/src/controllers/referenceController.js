const { CATEGORIES, TARGET_AUDIENCES } = require('../constants/referenceData');

function getReferenceData(req, res) {
  try {
    return res.status(200).json({
      success: true,
      data: {
        categories: CATEGORIES,
        targetAudiences: TARGET_AUDIENCES
      }
    });
  } catch (error) {
    console.error('Error getReferenceData:', error);
    return res.status(500).json({
      success: false,
      message: 'Gagal memuat data referensi.'
    });
  }
}

module.exports = {
  getReferenceData
};
