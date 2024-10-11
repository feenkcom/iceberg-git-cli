Class {
	#name : #GitCliFileHandle,
	#superclass : #FileSystemHandle,
	#instVars : [
		'entry'
	],
	#category : #'Iceberg-Git-CLI-Core'
}

{ #category : #streams }
GitCliFileHandle >> binaryReadStream [
	^ reference fileSystem store binaryReadStreamOn: self
]

{ #category : #accessing }
GitCliFileHandle >> entry [
	^ entry
]

{ #category : #public }
GitCliFileHandle >> open [
	entry := self basicOpen
]
