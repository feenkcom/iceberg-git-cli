Class {
	#name : #PureGitBlob,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'id',
		'contents'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitBlob >> contents [
	^ contents ifNil: [ contents := self repository contentsOfBlob: self id ]
]

{ #category : #accessing }
PureGitBlob >> contents: aByteArray [
	contents := aByteArray
]

{ #category : #'as yet unclassified' }
PureGitBlob >> gtDetails [
	^ super gtDetails , {
		{ 'blob' . self id }.
		{ 'contents'
			. '{1} bytes' format: { self contents size }
			. self contents }
	}
]

{ #category : #accessing }
PureGitBlob >> id [
	^ id
]

{ #category : #accessing }
PureGitBlob >> id: aString [
	id := aString
]

{ #category : #printing }
PureGitBlob >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	self id ifNotNil: [
		stream nextPutAll: id.
		stream space.
		stream print: self contents size.
		stream space.
		stream nextPut: $B ].
	stream nextPut: $)
]
