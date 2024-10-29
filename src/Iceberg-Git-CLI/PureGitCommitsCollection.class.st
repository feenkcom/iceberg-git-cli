"
I hold an ordered collection of git commits
"
Class {
	#name : #PureGitCommitsCollection,
	#superclass : #Object,
	#traits : 'TGtGroupWithItems',
	#classTraits : 'TGtGroupWithItems classTrait',
	#category : #'Iceberg-Git-CLI-Pure'
}

{ #category : #'as yet unclassified' }
PureGitCommitsCollection >> gtViewItemsFor: composite [
	<gtView>
	| timestampFormat |
	timestampFormat := ZTimestampFormat fromString: '2001-02-03 16:05'.
	^ composite columnedList
		title: 'Commits';
		priority: 20;
		items: [ self items ];
		column: '#' text: [ :_ :index | index asRopedText foreground: Color gray ] weight: 0.25;
		column: 'Commit' text: [ :commit | commit shortCommitId ] weight: 0.5;
		column: 'Timestamp' text: [ :commit | timestampFormat format: commit timestamp ] weight: 0.5;
		column: 'Author' text: [ :commit | commit author ];
		column: 'Comment' text: [ :commit | commit comment firstLineWithEllipsis ] weight: 2
]
