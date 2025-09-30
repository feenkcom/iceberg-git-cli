"
I model a git repository that exists at a specific location.

I use a git command line interface to interact with my on disk repository.

I do not know anything about Iceberg or Pharo code, I only deal with files.
"
Class {
	#name : #PureGitRepository,
	#superclass : #Object,
	#instVars : [
		'location',
		'exists',
		'hasHead',
		'announcer'
	],
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #'instance creation' }
PureGitRepository class >> forFile: aFileReference [
	"Answer the receiver holding the supplied file, or nil if the file isn't in git version control.
	This will search up to and excluding the root directory, even if it crosses a file system."
	| fileReference currentDir |

	fileReference := aFileReference asFileReference.
	(fileReference isDirectory and: [ (fileReference / '.git') isDirectory ]) ifTrue:
		[ self on: fileReference ].

	currentDir := fileReference isDirectory
		ifTrue: [ fileReference ]
		ifFalse: [ fileReference parent ].
	[ currentDir isRoot ] whileFalse:
		[ (currentDir / '.git') isDirectory ifTrue: [ ^ self on: currentDir ].
		currentDir := currentDir parent ].
	^ nil
]

{ #category : #'instance creation' }
PureGitRepository class >> on: aFileReference [
	^ self new
		location: aFileReference;
		yourself
]

{ #category : #private }
PureGitRepository >> announceRepositoryModified [
	self announcer
		announce: (PureGitRepositoryModified new
				repository: self;
				yourself)
]

{ #category : #accessing }
PureGitRepository >> announcer [
	^ announcer
]

{ #category : #convenience }
PureGitRepository >> branch [
	^ self queries branch
]

{ #category : #private }
PureGitRepository >> deleted [
	exists := false.
	hasHead := false.
]

{ #category : #accessing }
PureGitRepository >> diffTool [
	^ PureGitDiffTool inRepository: self
]

{ #category : #accessing }
PureGitRepository >> dotGitDirectory [
	^ self location / '.git'
]

{ #category : #private }
PureGitRepository >> ensureLocation [
	(location notNil and: [ location exists not ])
		ifTrue: [ location ensureCreateDirectory ].
	^ location
]

{ #category : #testing }
PureGitRepository >> exists [
	^ exists or: [ exists := location notNil and: [ self dotGitDirectory exists ] ]
]

{ #category : #testing }
PureGitRepository >> hasDetachedHead [
	^ self queries currentBranchName isEmpty
]

{ #category : #testing }
PureGitRepository >> hasHead [
	^ hasHead
		or: [ hasHead := self exists
					and: [ [ self queries resolveHead notEmpty ]
							on: GtGitCliCommandError
							do: [ false ] ] ]
]

{ #category : #convenience }
PureGitRepository >> head [
	^ self queries head
]

{ #category : #initialization }
PureGitRepository >> initialize [
	super initialize.
	exists := false.
	hasHead := false.
	announcer := Announcer new.
]

{ #category : #testing }
PureGitRepository >> isCodeRepository [
	^ false
]

{ #category : #accessing }
PureGitRepository >> location [
	^ location
]

{ #category : #initialization }
PureGitRepository >> location: aFileReference [
	location := aFileReference
]

{ #category : #convenience }
PureGitRepository >> log [
	^ self queries log
]

{ #category : #accessing }
PureGitRepository >> operations [
	^ PureGitOperations inRepository: self
]

{ #category : #printing }
PureGitRepository >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	location ifNotNil: [ location printOn: stream ].
	stream nextPut: $)
]

{ #category : #accessing }
PureGitRepository >> queries [
	^ PureGitQueries inRepository: self
]

{ #category : #accessing }
PureGitRepository >> resolveBlob: blobId [
	^ (PureGitBlob inRepository: self)
		id: blobId;
		yourself
]

{ #category : #accessing }
PureGitRepository >> resolveDirectory [
	^ PureGitDirectory inRepository: self
]

{ #category : #accessing }
PureGitRepository >> resolveDirectoryPath: relativePathString [
	^ (PureGitDirectory inRepository: self)
		path: relativePathString;
		yourself
]

{ #category : #accessing }
PureGitRepository >> resolveFilePath: relativePathString [
	^ (PureGitFile inRepository: self)
		path: relativePathString;
		yourself
]

{ #category : #accessing }
PureGitRepository >> resolveFileReference: fileReference [
	| path |
	path := (fileReference relativeTo: self location) pathString.
	^ fileReference isFile
		ifTrue: [ self resolveFilePath: path ]
		ifFalse: [ self resolveDirectoryPath: path ]
]

{ #category : #accessing }
PureGitRepository >> resolveTree: treeId [
	^ (PureGitTree inRepository: self)
		id: treeId;
		yourself
]

{ #category : #convenience }
PureGitRepository >> status [
	^ self queries status
]
