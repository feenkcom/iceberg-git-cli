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
	| first |
	extendedCommits := self file logPatch.
	extendedCommits := extendedCommits toArray wait reverse.
	first := true.
	extendedCommits overlappingPairsDo: [ :parent :each |
		first ifTrue: [
			parent initializeAsFirst.
			first := false ].
		each initializeFromParent: parent ]
]

{ #category : #accessing }
PureGitExtendedFileAnalysis >> commits [
	^ extendedCommits
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
