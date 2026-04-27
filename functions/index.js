const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// This function listens for any writes (creates, updates, deletes) to the 'users' collection
exports.syncUserRoleToAuth = functions.firestore
  .document("users/{userId}")
  .onWrite(async (change, context) => {
    const userId = context.params.userId;

    // If the document was deleted, remove the custom claims
    if (!change.after.exists) {
      console.log(`User ${userId} deleted. Removing claims.`);
      return admin.auth().setCustomUserClaims(userId, null);
    }

    // Get the data from the newly created/updated document
    const userData = change.after.data();
    const userRole = userData.role;

    // If there is no role, exit the function
    if (!userRole) {
      console.log(`No role found for user ${userId}.`);
      return null;
    }

    try {
      // Attach the role to the user's Auth Token as a Custom Claim
      await admin.auth().setCustomUserClaims(userId, { role: userRole });
      console.log(`Successfully assigned role '${userRole}' to user ${userId}`);
      return null;
    } catch (error) {
      console.error("Error setting custom claim:", error);
      return null;
    }
  });