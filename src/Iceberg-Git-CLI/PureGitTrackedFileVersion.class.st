Class {
	#name : #PureGitTrackedFileVersion,
	#superclass : #Object,
	#instVars : [
		'lines',
		'versionNumber',
		'commit',
		'trackedFile'
	],
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #operations }
PureGitTrackedFileVersion >> commit [
	^ commit
]

{ #category : #operations }
PureGitTrackedFileVersion >> commit: aCommit [ 
	commit := aCommit
]

{ #category : #'as yet unclassified' }
PureGitTrackedFileVersion >> gtViewKumpelFor: composite [
	<gtView>
	^ composite explicit
		title: 'Kumpel';
		priority: 60;
		tooltip: 'Show line history over time';
		stencil: [ | container colors |
			colors := BrExplicitIdentityNormalizer new
					colors: BrGlamorousColors distinctTenLightColors;
					defaultColor: Color veryLightGray.
			container := BlElement new.
			container
				constraintsDo: [ :c | 
					c horizontal matchParent.
					c vertical matchParent ].
			trackedFile uniqueTrackedLines
				do: [ :trackedLine | 
					| element |
					element := trackedLine asKumpelGraphElement.
					element
						background: (colors value: (trackedFile authorOfTrackedLine: trackedLine)).
					element
						border: (colors value: (trackedFile authorOfTrackedLine: trackedLine)).
					container addChild: element ].
			container
				addChild: (BlElement new
						background: (Color black alpha: 0.3);
						zIndex: 100;
						size: PureGitTrackedLine versionWidth @ (PureGitTrackedLine lineHeight * (lines size));
						relocate: ((versionNumber - 1)
								* (PureGitTrackedLine versionWidth + PureGitTrackedLine versionMargin))
								@ 0).
			container ]
]

{ #category : #'as yet unclassified' }
PureGitTrackedFileVersion >> lines [ 
	^ lines
]

{ #category : #operations }
PureGitTrackedFileVersion >> lines: aCollectionOfTrackedLines [ 
	lines := aCollectionOfTrackedLines
]

{ #category : #operations }
PureGitTrackedFileVersion >> trackedFile: aTrackedFile [ 
	trackedFile := aTrackedFile
]

{ #category : #'as yet unclassified' }
PureGitTrackedFileVersion >> versionNumber [
	^ versionNumber
]

{ #category : #operations }
PureGitTrackedFileVersion >> versionNumber: aNumber [ 
	versionNumber := aNumber
]
