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

{ #category : #constants }
PureGitTrackedLine class >> lineHeight [
	^ 5
]

{ #category : #constants }
PureGitTrackedLine class >> versionMargin [
	^ 2
]

{ #category : #constants }
PureGitTrackedLine class >> versionWidth [
	^ 40
]

{ #category : #accessing }
PureGitTrackedLine >> endVersion [
	| end |
	end := 0.
	self positionsInVersions reverse
		doWithIndex: [ :each :index | 
			(end isZero and: each isZero not)
				ifTrue: [ end := self positionsInVersions size - index ] ].
	^ end
]

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
	stream
		nextPut: $(;
		nextPutAll: line;
		nextPut: $);
		space;
		nextPutAll: self startVersion asString;
		nextPutAll: '-';
		nextPutAll: self endVersion asString
]

{ #category : #accessing }
PureGitTrackedLine >> startVersion [
	| start |
	start := 0.
	self positionsInVersions
		doWithIndex: [ :each :index | (start isZero and: each isZero not) ifTrue: [ start := index ] ].
	^ start
]
