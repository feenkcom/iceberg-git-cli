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
IceGitCliCommit >> packageNames [
	"Do not cache an empty answer: it is almost always the result of a transient state of the commit file system, and caching it makes every package look new in diffs until the image is restarted."

	| cache names |
	cache := self repository commitsInPackageCache.
	names := cache at: self ifAbsentPut: [ self fetchPackageNames ].
	names isEmpty ifTrue: [ cache removeKey: self ifAbsent: [ nil ] ].
	^ names
]

{ #category : #accessing }
IceGitCliCommit >> project [
	^project ifNil: [project := super project]
]

{ #category : #'accessing - file' }
IceGitCliCommit >> resetFileSystem [
	filesystem ifNotNil: [ filesystem store finalize ].
	filesystem := nil
]

{ #category : #accessing }
IceGitCliCommit >> tags [
	^ self repository tagsFor: id
]
