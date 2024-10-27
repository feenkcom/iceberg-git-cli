"
I am a collection of PureGitExtendedFileCommits, the result of an analysis of the historic evolution of one file.
"
Class {
	#name : #PureGitExtendedFileAnalysis,
	#superclass : #Object,
	#instVars : [
		'file',
		'extendedCommits'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #operations }
PureGitExtendedFileAnalysis >> analyze [
	| previous |
	extendedCommits := self file logPatchReverse.
	previous := nil.
	extendedCommits := (extendedCommits
			collect: [ :each | 
				previous
					ifNil: [ each initializeAsFirst ]
					ifNotNil: [ each initializeFromParent: previous ].
				previous := each ]) cached
]

{ #category : #accessing }
PureGitExtendedFileAnalysis >> commits [
	^ extendedCommits asyncSimilarCopy
]

{ #category : #accessing }
PureGitExtendedFileAnalysis >> file [
	^ file
]

{ #category : #accessing }
PureGitExtendedFileAnalysis >> file: aGitFile [
	file := aGitFile
]

{ #category : #accessing }
PureGitExtendedFileAnalysis >> path [
	^ self file path
]

{ #category : #printing }
PureGitExtendedFileAnalysis >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: self path.
	stream nextPut: $)
]
