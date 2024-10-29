"
I support the implementation of a file system on an entry of a specific git commit.
"
Class {
	#name : #PureGitCommitFileSystemHandle,
	#superclass : #FileSystemHandle,
	#instVars : [
		'entry'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #streams }
PureGitCommitFileSystemHandle >> binaryReadStream [
	^ reference fileSystem store binaryReadStreamOn: self
]

{ #category : #accessing }
PureGitCommitFileSystemHandle >> entry [
	^ entry
]

{ #category : #public }
PureGitCommitFileSystemHandle >> open [
	entry := self basicOpen
]
