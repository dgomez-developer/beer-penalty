import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin'
admin.initializeApp()

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

exports.sendNotification = functions.firestore
 .document('users/{userId}')
 .onUpdate((snap, context) => {
    console.log('--------- Function Started ----------')
    
    const docBefore = snap?.before?.data()
    const doc = snap?.after?.data()
    console.log(doc)

    const beers = doc?.beers
    const beersBefore = docBefore?.beers
    const userName = doc?.userName
    const fcmToken = doc?.fcmToken
    const payload = {
        notification: {
            title: userName + (beers > beersBefore) ? ' a new beer fur dich!' : ' someone forgave you a beer!',
            body: 'Currently, you have a total of ' + beers + ' beers',
            badge:  '1',
            sound:  'default'
        }
    }
    admin.messaging()
        .sendToDevice(fcmToken, payload)
        .then(response => {
            console.log('Message sucessfully sent to: ', userName)
        })
        .catch(error => {
            console.log('Error sending message: ', error)
        })
    return null
})
