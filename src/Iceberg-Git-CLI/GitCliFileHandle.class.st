Class {
	#name : #GitCliFileHandle,
	#superclass : #FileSystemHandle,
	#instVars : [
		'entry'
	],
	#category : #'Iceberg-Git-CLI-Core'
}

{ #category : #accessing }
GitCliFileHandle >> binaryReadStream [
	^ reference fileSystem store binaryReadStreamOn: self
]

{ #category : #accessing }
GitCliFileHandle >> entry [
	^ entry
]

{ #category : #accessing }
GitCliFileHandle >> open [
	entry := self basicOpen
]
