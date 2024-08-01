import * as v2 from 'firebase-functions/v2';
import * as admin from 'firebase-admin';


admin.initializeApp();

// Need to be on a billing plan to use cloud functions
// exports.deleteOldTrashedNotes = v2.pubsub.schedule('every 24 hours').onRun(async () => {
//     try {
//       const thirtyDaysAgo = admin.firestore.Timestamp.fromDate(new Date(Date.now() - 30 * 24 * 60 * 60 * 1000));
      
//       const snapshot = await admin.firestore().collection('notesTrash')
//         .where('deletedTime', '<', thirtyDaysAgo)
//         .get();
  
//       const batch = admin.firestore().batch();
//       snapshot.docs.forEach((doc) => {
//         batch.delete(doc.ref);
//       });
  
//       await batch.commit();
  
//       console.log(`Deleted ${snapshot.size} old trashed notes.`);
//     } catch (error) {
//       console.error('Error deleting old trashed notes:', error);
//     }
//     return null;
//   });