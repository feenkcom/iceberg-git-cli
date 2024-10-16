"
I am a collection of UnifiedDiffs with changes to different files
"
Class {
	#name : #UnifiedDiffCollection,
	#superclass : #Object,
	#instVars : [
		'diffs'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
UnifiedDiffCollection >> changedPaths [
	^ self diffs flatCollect: #paths
]

{ #category : #accessing }
UnifiedDiffCollection >> children [
	^ self diffs
]

{ #category : #accessing }
UnifiedDiffCollection >> description [
	^ String streamContents: [ :out |
		out nextPutAll: (self numberOfChanges pluralize: 'changed file').
		out nextPutAll: ' with '.
		out nextPutAll: (self numberOfLinesAdded pluralize: 'addition').
		out nextPutAll: ' and '.
		out nextPutAll: (self numberOfLinesRemoved pluralize: 'deletion') ]
]

{ #category : #accessing }
UnifiedDiffCollection >> diffs [
	^ diffs
]

{ #category : #accessing }
UnifiedDiffCollection >> firstDiff [
	^ diffs first
]

{ #category : #initialization }
UnifiedDiffCollection >> initialize [
	super initialize.
	diffs := OrderedCollection new
]

{ #category : #testing }
UnifiedDiffCollection >> isEmpty [
	^ diffs isEmpty
]

{ #category : #accessing }
UnifiedDiffCollection >> numberOfChanges [
	^ self diffs size
]

{ #category : #accessing }
UnifiedDiffCollection >> numberOfLinesAdded [
	^ self diffs sum: [ :each | each numberOfLinesAdded ]
]

{ #category : #accessing }
UnifiedDiffCollection >> numberOfLinesRemoved [
	^ self diffs sum: [ :each | each numberOfLinesRemoved ]
]

{ #category : #printing }
UnifiedDiffCollection >> printOn: stream [
	super printOn: stream.
	stream nextPut: $(.
	stream nextPutAll: (diffs size pluralize: 'diffs').
	stream nextPut: $)
]

{ #category : #parsing }
UnifiedDiffCollection >> readFrom: stream [
	[ stream atEnd ] whileFalse: [
		diffs add: (UnifiedDiff new readFrom: stream) ]
]
