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
