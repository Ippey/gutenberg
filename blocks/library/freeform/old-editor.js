/**
 * WordPress dependencies
 */
import { Component } from 'element';

export default class OldEditor extends Component {
	constructor( props ) {
		super( props );
		this.initialize = this.initialize.bind( this );
		this.onSetup = this.onSetup.bind( this );
	}

	componentDidMount() {
		const { baseURL, suffix } = window.tinyMCEPreInit;

		window.tinymce.EditorManager.overrideDefaults( {
			base_url: baseURL,
			suffix,
		} );

		if ( document.readyState === 'complete' ) {
			this.initialize();
		} else {
			window.addEventListener( 'DOMContentLoaded', this.initialize );
		}
	}

	componentWillUnmount() {
		window.addEventListener( 'DOMContentLoaded', this.initialize );
		wp.oldEditor.remove( this.props.id );
	}

	componentDidUpdate( prevProps ) {
		const { id, attributes: { content } } = this.props;

		if ( prevProps.attributes.content !== content ) {
			window.tinymce.get( id ).setContent( content || '' );
		}
	}

	initialize() {
		const { id } = this.props;

		wp.oldEditor.initialize( id, {
			tinymce: {
				inline: true,
				content_css: false,
				fixed_toolbar_container: '#' + id + '-toolbar',
				toolbar1: 'formatselect | alignleft aligncenter alignright | bullist numlist blockquote | bold italic strikethrough link | kitchensink',
				toolbar2: 'hr wp_more forecolor pastetext removeformat charmap outdent indent undo redo',
				setup: this.onSetup,
			},
		} );
	}

	onSetup( editor ) {
		const { attributes: { content }, setAttributes } = this.props;
		const { ref } = this;

		editor.on( 'loadContent', () => editor.setContent( content || '' ) );

		editor.on( 'blur', () => {
			setAttributes( {
				content: editor.getContent(),
			} );
		} );

		editor.addButton( 'kitchensink', {
			tooltip: 'Toolbar Toggle',
			icon: 'dashicon dashicons-editor-kitchensink',
			onClick: function() {
				const button = this;
				const active = ! button.active();

				button.active( active );
				editor.dom.toggleClass( ref, 'has-advanced-toolbar', active );
			},
		} );
	}

	render() {
		const { id } = this.props;

		return [
			<div
				key="toolbar"
				id={ id + '-toolbar' }
				ref={ ref => this.ref = ref }
				className="editor-visual-editor__block-controls freeform-toolbar"
			/>,
			<div
				key="editor"
				id={ id }
				className="blocks-editable__tinymce"
			/>,
		];
	}
}
