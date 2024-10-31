"
I model how a line moves position across versions
"
Class {
	#name : #PureGitTrackedLine,
	#superclass : #Object,
	#instVars : [
		'line',
		'positionInVersions'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #initialization }
PureGitTrackedLine >> initializeForNumberOfVersions: count [
	positionInVersions := Array new: count withAll: 0
]

{ #category : #accessing }
PureGitTrackedLine >> line [
	^ line
]

{ #category : #accessing }
PureGitTrackedLine >> line: aString [
	line := aString
]

{ #category : #accessing }
PureGitTrackedLine >> positionInVersionAt: index [
	^ positionInVersions at: index
]

{ #category : #accessing }
PureGitTrackedLine >> positionInVersionAt: index put: lineNumber [
	^ positionInVersions at: index put: lineNumber
]

{ #category : #accessing }
PureGitTrackedLine >> positionsInVersions [
	^ positionInVersions
]

{ #category : #printing }
PureGitTrackedLine >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(; nextPutAll: line; nextPut: $)
]
