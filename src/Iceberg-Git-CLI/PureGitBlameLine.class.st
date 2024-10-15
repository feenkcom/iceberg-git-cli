"
I match a text line at a line number with the commit that last changed it.
I am the result of git blame. 
"
Class {
	#name : #PureGitBlameLine,
	#superclass : #Object,
	#instVars : [
		'line',
		'lineNumber',
		'commit'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitBlameLine >> author [
	^ commit author
]

{ #category : #accessing }
PureGitBlameLine >> commit [
	^ commit
]

{ #category : #accessing }
PureGitBlameLine >> commit: aHash [
	commit := aHash
]

{ #category : #accessing }
PureGitBlameLine >> line [
	^ line
]

{ #category : #accessing }
PureGitBlameLine >> line: aString [
	line := aString
]

{ #category : #accessing }
PureGitBlameLine >> lineNumber [
	^ lineNumber
]

{ #category : #accessing }
PureGitBlameLine >> lineNumber: anInteger [
	lineNumber := anInteger
]

{ #category : #operations }
PureGitBlameLine >> resolveCommitIn: repository using: cache [
	commit := cache 
		at: commit 
		ifAbsentPut: [ repository resolveCommit: commit ]
]

{ #category : #accessing }
PureGitBlameLine >> shortId [
	^ commit shortCommitId
]

{ #category : #accessing }
PureGitBlameLine >> timestamp [
	^ commit timestamp
]
