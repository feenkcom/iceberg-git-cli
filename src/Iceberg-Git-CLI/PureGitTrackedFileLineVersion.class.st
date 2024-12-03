"
I model one line of a tracked file at a specific version/commit within the context of the full history.
"
Class {
	#name : #PureGitTrackedFileLineVersion,
	#superclass : #Object,
	#instVars : [
		'file',
		'line'
	],
	#category : #'Iceberg-Git-CLI-Pure-Analysis'
}

{ #category : #printing }
PureGitTrackedFileLineVersion >> commit [
	^ self extendedCommit commit
]

{ #category : #printing }
PureGitTrackedFileLineVersion >> extendedCommit [
	^ self file commit
]

{ #category : #accessing }
PureGitTrackedFileLineVersion >> file [
	^ file
]

{ #category : #accessing }
PureGitTrackedFileLineVersion >> file: aTrackedFile [
	file := aTrackedFile
]

{ #category : #accessing }
PureGitTrackedFileLineVersion >> line [
	^ line
]

{ #category : #accessing }
PureGitTrackedFileLineVersion >> line: aTrackedLine [
	line := aTrackedLine
]

{ #category : #accessing }
PureGitTrackedFileLineVersion >> lineContents [
	^ self line line
]

{ #category : #accessing }
PureGitTrackedFileLineVersion >> lineNumber [
	^ self line positionInVersionAt: self file versionNumber
]

{ #category : #printing }
PureGitTrackedFileLineVersion >> path [
	^ self file trackedFile path
]

{ #category : #printing }
PureGitTrackedFileLineVersion >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self path;
		space;
		nextPut: $@;
		print: self lineNumber;
		space;
		nextPutAll: self commit shortId;
		nextPut: $)
]

{ #category : #accessing }
PureGitTrackedFileLineVersion >> trackedFile [
	^ self file trackedFile
]
