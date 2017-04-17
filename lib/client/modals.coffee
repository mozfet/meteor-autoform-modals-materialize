registeredAutoFormHooks = ['cmForm']

AutoForm.addHooks 'cmForm',
	onSuccess: ->
		modalClose()
		return

collectionObj = (name) ->
	name.split('.').reduce (o, x) ->
		o[x]
	, window

#workaround for different modal apis
modalClose = ->

	#use poetic:materialize-scss openModal api (trailing materialize api)
	if Package['poetic:materialize-scss']
		console.log 'using poetic:materialize.modal close'
		$('#afModal').modal 'close'

	#else use materialize:materialize modal api
	else if Package['materialize:materialize']
		console.log 'using poetic:materialize.closeModal'
		$('#afModal').closeModal()

#workaround for different modal apis
modalOpen = (complete) ->

		#use poetic:materialize-scss openModal api (trailing materialize api)
		if Package['poetic:materialize-scss']
			console.log 'using poetic:materialize.openModal'
			$('#afModal').openModal
				complete: complete

		#else use materialize:materialize modal api
		else if Package['materialize:materialize']
			console.log 'using materialize:materialize.modal'
			$('#afModal').modal
			  complete: complete
			$('#afModal').modal	'open'

		#else - warn that dependancies not found
		else
			console.warn 'could not find materialize:materialize nor poetic:materlialize-scss package'

Template.autoformModals.events
	'click button:not(.close)': () ->
		collection = Session.get 'cmCollection'
		operation = Session.get 'cmOperation'

		if operation != 'insert'
			_id = Session.get('cmDoc')._id

		if operation == 'remove'
			collectionObj(collection).remove _id, (e) ->
				if e
					alert 'Sorry, this could not be deleted.'
				else
					modalClose()
		return

	'click [data-action="submit"]': (event, template) ->
		event.preventDefault()
		template.$('form').submit()
		return

	'click [data-action="cancel"]': (event, template) ->
		event.preventDefault()
		modalClose
		return

helpers =
	cmFormId: () ->
		Session.get 'cmFormId'
	cmCollection: () ->
		Session.get 'cmCollection'
	cmSchema: () ->
		Session.get 'cmSchema'
	cmOperation: () ->
		Session.get 'cmOperation'
	cmDoc: () ->
		Session.get 'cmDoc'
	cmButtonHtml: () ->
		Session.get 'cmButtonHtml'
	cmFields: () ->
		Session.get 'cmFields'
	cmOmitFields: () ->
		Session.get 'cmOmitFields'
	cmButtonContent: () ->
		Session.get 'cmButtonContent'
	cmButtonCancelContent: () ->
		Session.get 'cmButtonCancelContent'
	cmTitle: () ->
		Session.get 'cmTitle'
	cmButtonClasses: () ->
		Session.get 'cmButtonClasses'
	cmButtonSubmitClasses: () ->
		Session.get 'cmButtonSubmitClasses'
	cmButtonCancelClasses: () ->
		Session.get 'cmButtonCancelClasses'
	cmPrompt: () ->
		Session.get 'cmPrompt'
	cmTemplate: () ->
		Session.get 'cmTemplate'
	cmLabelClass: () ->
		Session.get 'cmLabelClass'
	cmInputColClass: () ->
		Session.get 'cmInputColClass'
	cmPlaceholder: () ->
		Session.get 'cmPlaceholder'
	cmFormId: () ->
		Session.get('cmFormId') or 'cmForm'
	title: () ->
		StringTemplate.compile '{{{cmTitle}}}', helpers
	prompt: () ->
		StringTemplate.compile '{{{cmPrompt}}}', helpers

Template.autoformModals.helpers helpers

Template.autoformModals.destroyed = -> $('body').unbind 'click'

Template.afModal.events
	'click *': (e, t) ->
		e.preventDefault()

		html = t.$('*').html()

		formId = t.data.formId or "cmForm"
		Session.set 'cmFormId', formId
		Session.set 'cmCollection', t.data.collection
		Session.set 'cmSchema', t.data.schema
		Session.set 'cmOperation', t.data.operation
		Session.set 'cmFields', t.data.fields
		Session.set 'cmOmitFields', t.data.omitFields
		Session.set 'cmButtonHtml', html
		Session.set 'cmTitle', t.data.title
		Session.set 'cmTemplate', t.data.template
		Session.set 'cmLabelClass', t.data.labelClass
		Session.set 'cmInputColClass', t.data.inputColClass
		Session.set 'cmPlaceholder', if t.data.placeholder is true then 'schemaLabel' else ''

		console.log t

		if not _.contains registeredAutoFormHooks, formId
			AutoForm.addHooks formId,
				onSuccess: ->
					modalClose()
					return

			registeredAutoFormHooks.push formId

		if t.data.doc and typeof t.data.doc == 'string'
			Session.set 'cmDoc', collectionObj(t.data.collection).findOne _id: t.data.doc

		if t.data.buttonContent
			Session.set 'cmButtonContent', t.data.buttonContent
		else if t.data.operation == 'insert'
			Session.set 'cmButtonContent', 'Create'
		else if t.data.operation == 'update'
			Session.set 'cmButtonContent', 'Update'
		else if t.data.operation == 'remove'
			Session.set 'cmButtonContent', 'Delete'

		if t.data.buttonCancelContent
			Session.set 'cmButtonCancelContent', t.data.buttonCancelContent
		else
			Session.set 'cmButtonCancelContent', 'Cancel'

		defaultButtonClasses = 'waves-effect btn-flat modal-action'
		if t.data.buttonClasses
			Session.set 'cmButtonClasses', t.data.buttonClasses
			Session.set 'cmButtonCancelClasses', t.data.buttonClasses
			Session.set 'cmButtonSubmitClasses', t.data.buttonClasses
		else
			Session.set 'cmButtonClasses', defaultButtonClasses
			Session.set 'cmButtonCancelClasses', defaultButtonClasses
			Session.set 'cmButtonSubmitClasses', defaultButtonClasses

		if t.data.buttonSubmitClasses
			Session.set 'cmButtonSubmitClasses', t.data.buttonSubmitClasses
		else
			Session.set 'cmButtonSubmitClasses', defaultButtonClasses

		if t.data.buttonCancelClasses
			Session.set 'cmButtonCancelClasses', t.data.buttonCancelClasses
		else
			Session.set 'cmButtonCancelClasses', defaultButtonClasses

		if t.data.prompt
			Session.set 'cmPrompt', t.data.prompt
		else if t.data.operation == 'remove'
			Session.set 'cmPrompt', 'Are you sure?'
		else
			Session.set 'cmPrompt', ''

		# add modal to page container... not sure its safe though
		modalParentQuerySize = $('#modalContainer').size()
		console.log 'modalParentQuery size', modalParentQuerySize
		if modalParentQuerySize == 0
			containerQuery = $('.container')
			console.log 'containerQuery', containerQuery
			containerQuery.append '<div id="modalContainer"></div>'
		modalParentQuery = $('#modalContainer')
		modalParentQuery.empty()
		modalParentNode = modalParentQuery[0]
		console.log 'modalParentNode', modalParentNode
		modalData = {
			title: 'title'
		}
		Blaze.renderWithData Template.autoformModals, modalData, modalParentNode
		console.log 'leanModal', $('#afModal')

		#define session keys for deletion
		sessionKeys = [
			'cmCollection',
			'cmSchema',
			'cmOperation',
			'cmDoc',
			'cmButtonHtml',
			'cmFields',
			'cmOmitFields',
			'cmButtonContent',
			'cmTitle',
			'cmButtonClasses',
			'cmPrompt',
			'cmTemplate',
			'cmLabelClass',
			'cmInputColClass',
			'cmPlaceholder'
		]

		#define complete function
		complete = ->
			delete Session.keys[key] for key in sessionKeys
			return

		#open modal
		modalOpen(complete)

		return
