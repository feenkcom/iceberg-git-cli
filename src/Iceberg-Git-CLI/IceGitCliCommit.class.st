Class {
	#name : #IceGitCliCommit,
	#superclass : #IceGitCommit,
	#instVars : [
		'project',
		'filesystem'
	],
	#category : #'Iceberg-Git-CLI-Core'
}

{ #category : #ancestry }
IceGitCliCommit >> commonAncestorWithCommit: anIceGitCommit [
	| mergeBaseId |
	mergeBaseId := repository mergeBaseBetween: id and: anIceGitCommit id.
	^ mergeBaseId ifNotNil: [ self repository lookupCommit: mergeBaseId ]
]

{ #category : #accessing }
IceGitCliCommit >> entryByPath: aString ifAbsent: aBlock [
	| ref |
	ref := self fileSystem resolveString: aString.
	^ ref exists ifTrue: [ ref ] ifFalse: [ aBlock value ]
]

{ #category : #'accessing - file' }
IceGitCliCommit >> fileSystem [
	filesystem
		ifNil: [ filesystem := FileSystem store: (GitCliCommitStore on: self) ].
	^ filesystem root
]

{ #category : #testing }
IceGitCliCommit >> isCurrentHead [

	^ (repository location / '.git' / 'HEAD') contents trimRight = id
]

{ #category : #accessing }
IceGitCliCommit >> numberOfParents [
	^self ancestorIds size
]

{ #category : #accessing }
IceGitCliCommit >> project [
	^project ifNil: [project := super project]
]

{ #category : #'accessing - file' }
IceGitCliCommit >> resetFileSystem [
	filesystem := nil
]

{ #category : #accessing }
IceGitCliCommit >> tags [
	^ self repository tagsFor: id
]
