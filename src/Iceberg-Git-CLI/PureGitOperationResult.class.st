"
I hold the result of a git operation
"
Class {
	#name : #PureGitOperationResult,
	#superclass : #PureGitRepositoryObject,
	#instVars : [
		'operation',
		'arg',
		'result',
		'duration'
	],
	#category : #'Iceberg-Git-CLI-Pure-Core'
}

{ #category : #accessing }
PureGitOperationResult >> arg [
	^ arg
]

{ #category : #accessing }
PureGitOperationResult >> arg: anObject [
	arg := anObject
]

{ #category : #accessing }
PureGitOperationResult >> description [
	^ String
		streamContents: [ :out | 
			out
				nextPutAll: 'git ';
				nextPutAll: (operation last = $: ifTrue: [ operation allButLast ] ifFalse: [ operation ]).
			arg ifNotNil: [ 
				arg isString
					ifTrue: [ out space; nextPutAll: arg ]
					ifFalse: [ arg do: [ :each | out space; nextPutAll: each ] ] ].
			duration
				ifNil: [ out nextPutAll: ' did not yet run' ]
				ifNotNil: [ | roundedDuration |
					roundedDuration := duration roundTo: 1 second.
					out nextPutAll: ' completed successfully'.
					roundedDuration >= 1 second
						ifTrue: [ out
								nextPutAll: ' in ';
								print: roundedDuration asSeconds;
								nextPut: $s ] ] ]
]

{ #category : #accessing }
PureGitOperationResult >> duration [
	^ duration
]

{ #category : #accessing }
PureGitOperationResult >> duration: aDuration [
	duration := aDuration
]

{ #category : #initialization }
PureGitOperationResult >> initialize [
	super initialize.
	operation := 'unknown'
]

{ #category : #accessing }
PureGitOperationResult >> operation [
	^ operation
]

{ #category : #accessing }
PureGitOperationResult >> operation: aString [
	operation := aString
]

{ #category : #printing }
PureGitOperationResult >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self description;
		nextPut: $)
]

{ #category : #accessing }
PureGitOperationResult >> result [
	^ result
]

{ #category : #accessing }
PureGitOperationResult >> result: anObject [
	result := anObject
]
