Class {
	#name : #PureGitTrackedLineSequence,
	#superclass : #Object,
	#instVars : [
		'lines'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #accessing }
PureGitTrackedLineSequence >> addLine: aLine [ 
	lines add: aLine
]

{ #category : #'as yet unclassified' }
PureGitTrackedLineSequence >> endVersion [
	^ self lines first endVersion
]

{ #category : #'as yet unclassified' }
PureGitTrackedLineSequence >> gtDisplayOn: stream [
	stream
		nextPutAll: self lines size asString;
		nextPutAll: ' lines ';
		nextPutAll: self startVersion asString;
		nextPutAll: '-';
		nextPutAll: self endVersion asString
]

{ #category : #'as yet unclassified' }
PureGitTrackedLineSequence >> gtLinesFor: aView [
	<gtView>
	^ aView list 
		title: 'Lines';
		items: [ self lines ]
]

{ #category : #'as yet unclassified' }
PureGitTrackedLineSequence >> initialize [
	super initialize.
	lines := OrderedCollection new
]

{ #category : #'as yet unclassified' }
PureGitTrackedLineSequence >> lines [
	^ lines
]

{ #category : #'as yet unclassified' }
PureGitTrackedLineSequence >> startVersion [
	^ self lines first startVersion
]
