"
I represent the binary contents of a git blob.

I am the lowest level of content addressable data in git.

I know my hash (id).

I hold no further meta data.
"
Class {
	#name : #PureGitBlob,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'id',
		'contents'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #utilities }
PureGitBlob class >> hashBytes: bytes [
	| encoding |
	encoding := ('blob {1}' format: { bytes size }) utf8Encoded , #[ 0 ], bytes.
	^ SHA1 hashMessage: encoding
]

{ #category : #utilities }
PureGitBlob class >> hashText: string [
	^ self hashBytes: string utf8Encoded
]

{ #category : #utilities }
PureGitBlob class >> imageTypeUsingMagicHeaderFrom: bytes [
	| stream |
	stream := bytes readStream.
	#( 
		#[16r42 16r4D] bmp
		#[16r89 16r50 16r4E 16r47 16r0D 16r0A 16r1A 16r0A] png
		#[16rFF 16rD8 16rFF] jpg
		#[16r47 16r49 16r46 16r38] gif ) pairsDo: [ :magic :type |
			(stream reset; next: magic size) = magic
				ifTrue: [ ^ type ] ].
	^ nil
]

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
	stream nextPutAll: self id.
	stream nextPut: $)
]

{ #category : #accessing }
PureGitBlob >> text [
	^ self contents utf8Decoded
]
