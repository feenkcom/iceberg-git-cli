"
I support the implementation of a file system on a specific git commit
"
Class {
	#name : #PureGitCommitFileSystemStore,
	#superclass : #FileSystemStore,
	#instVars : [
		'commit'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitCommitFileSystemStore >> accessTimeOf: aPath [
	^ commit timestamp asDateAndTime
]

{ #category : #private }
PureGitCommitFileSystemStore >> basenameFromEntry: aNode [
	^ aNode name
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicCreationTimeOf: aNode [
	^ commit timestamp asDateAndTime
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicEntry: aDirectoryEntry path: aPath nodesDo: aBlock [
	aDirectoryEntry entries do: aBlock
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicIsDirectory: aNode [
	^ aNode isTree
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicIsFile: aNode [
	^ aNode isTree not
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicIsWritable: aNode [
	^ false
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicModificationTime: aNode [
	^ commit timestamp asDateAndTime
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicModificationTimeOf: aNode [
	^ commit timestamp asDateAndTime
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicOpen: aPath writable: isWriteable [
	^ self
		nodeAt: aPath
		ifPresent: [ :entry | entry ]
		ifAbsent: [ isWriteable
				ifFalse: [ self signalFileDoesNotExist: aPath ]
				ifTrue: [ self shouldNotImplement ] ]
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicPosixPermissions: aNode [
	^ 8r444
]

{ #category : #private }
PureGitCommitFileSystemStore >> basicSizeOf: aNode [
	^ aNode size
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> binaryReadStreamOn: aFileHandle [
	^ aFileHandle entry contents readStream
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> changeTimeOf: aPath [
	^ commit timestamp asDateAndTime
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> commit [
	^ commit
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> commit: aCommit [
	commit := aCommit
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> delimiter [
	^ $/
]

{ #category : #printing }
PureGitCommitFileSystemStore >> forReferencePrintOn: aStream [
	aStream nextPutAll: 'git://'
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> gidOf: aPath [
	^ -1
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> handleClass [
	^ PureGitCommitFileSystemHandle
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> inodeOf: aPath [
	^ -1
]

{ #category : #testing }
PureGitCommitFileSystemStore >> isReadable: aPath [
	^ true
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> nodeAt: aPath ifPresent: aPresentBlock ifAbsent: anAbsentBlock [
	| entry |
	^ aPath isRoot
		ifTrue: [ aPresentBlock value: self commit tree ]
		ifFalse: [ 
			entry := self commit tree entryAtPath: aPath segments ifAbsent: anAbsentBlock.
			aPresentBlock value: entry resolve ]
]

{ #category : #printing }
PureGitCommitFileSystemStore >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(; nextPutAll: commit id; nextPut: $)
]

{ #category : #accessing }
PureGitCommitFileSystemStore >> uidOf: aResolvable [
	^ -1
]
