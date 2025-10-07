## Firestore Rules (öneri)

```
rules_version = '2';
service cloud.firestore {
	match /databases/{database}/documents {
		match /users/{userId} {
			allow read, write: if request.auth != null && request.auth.uid == userId;
		}

		match /trousseaus/{trousseauId} {
			allow read: if request.auth != null && (
				resource.data.ownerId == request.auth.uid ||
				request.auth.uid in resource.data.sharedWith ||
				request.auth.uid in resource.data.editors
			);
			allow create: if request.auth != null;
			allow update: if request.auth != null && (
				resource.data.ownerId == request.auth.uid ||
				request.auth.uid in resource.data.editors
			);
			allow delete: if request.auth != null && resource.data.ownerId == request.auth.uid;
		}

			match /products/{productId} {
				// For reads, use resource.data since the document already exists
				allow read: if request.auth != null &&
					exists(/databases/$(database)/documents/trousseaus/$(resource.data.trousseauId)) &&
					(
						get(/databases/$(database)/documents/trousseaus/$(resource.data.trousseauId)).data.ownerId == request.auth.uid ||
						request.auth.uid in get(/databases/$(database)/documents/trousseaus/$(resource.data.trousseauId)).data.sharedWith ||
						request.auth.uid in get(/databases/$(database)/documents/trousseaus/$(resource.data.trousseauId)).data.editors
					);
				// For writes, use request.resource.data (the incoming document)
				allow create, update, delete: if request.auth != null &&
					(
						get(/databases/$(database)/documents/trousseaus/$(request.resource.data.trousseauId)).data.ownerId == request.auth.uid ||
						request.auth.uid in get(/databases/$(database)/documents/trousseaus/$(request.resource.data.trousseauId)).data.editors
					);
			}
	}
}
```

# ceyiz_diz

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
