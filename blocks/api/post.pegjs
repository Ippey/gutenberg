{

function untransformValue( value ) {
	return 'string' === typeof value
		? value.replace( /\\-/g, '-' )
		: value;
}

/** <?php
// The `keyValuePair` function is not needed in PHP
// TODO: This is ignoring `untransformValue`
?> **/

function keyValuePair( key, value ) {
  const o = {};
  o[ key ] = untransformValue( value );
  return o;
}

}

Document
  = WP_Block_List

WP_Block_List
  = WP_Block*

WP_Block
  = WP_Block_Void
  / WP_Block_Balanced
  / WP_Block_Html

WP_Block_Void
  = "<!--" __ "wp:" blockName:WP_Block_Name attrs:HTML_Attribute_List _? "/-->"
  {
    /** <?php
    return array(
      'blockName'  => $blockName,
      'attrs'      => $attrs,
      'rawContent' => '',
    );
    ?> **/

    return {
      blockName: blockName,
      attrs: attrs,
      rawContent: ''
    };
  }

WP_Block_Balanced
  = s:WP_Block_Start ts:(!WP_Block_End c:Any {
    /** <?php return $c; ?> **/
    return c;
  })* e:WP_Block_End & {
    /** <?php return $s['blockName'] === $e['blockName']; ?> **/
    return s.blockName === e.blockName;
  }
  {
    /** <?php
    return array(
      'blockName'  => $s['blockName'],
      'attrs'      => $s['attrs'],
      'rawContent' => implode( '', $ts ),
    );
    ?> **/

    return {
      blockName: s.blockName,
      attrs: s.attrs,
      rawContent: ts.join( '' )
    };
  }

WP_Block_Html
  = ts:(!WP_Block_Balanced !WP_Block_Void c:Any {
    /** <?php return $c; ?> **/
    return c;
  })+
  {
    /** <?php
    return array(
      'attrs'      => array(),
      'rawContent' => implode( '', $ts ),
    );
    ?> **/

    return {
      attrs: {},
      rawContent: ts.join( '' )
    }
  }

WP_Block_Start
  = "<!--" __ "wp:" blockName:WP_Block_Name attrs:HTML_Attribute_List _? "-->"
  {
    /** <?php
    return array(
      'blockName' => $blockName,
      'attrs'     => $attrs,
    );
    ?> **/

    return {
      blockName: blockName,
      attrs: attrs
    };
  }

WP_Block_End
  = "<!--" __ "/wp:" blockName:WP_Block_Name __ "-->"
  {
    /** <?php
    return array(
      'blockName' => $blockName,
    );
    ?> **/

    return {
      blockName: blockName
    };
  }

WP_Block_Name
  = $(ASCII_Letter (ASCII_AlphaNumeric / "/" ASCII_AlphaNumeric)*)

HTML_Attribute_List
  = as:(_+ a:HTML_Attribute_Item {
    /** <?php return $a; ?> **/
    return a;
  })*
  {
    /** <?php
    return call_user_func_array( 'array_merge', $as );
    ?> **/

    return as.reduce( function( attrs, attr ) {
      return Object.assign( attrs, attr );
    }, {} );
  }

HTML_Attribute_Item
  = HTML_Attribute_Quoted
  / HTML_Attribute_Unquoted
  / HTML_Attribute_Empty

HTML_Attribute_Empty
  = name:HTML_Attribute_Name
  {
    /** <?php return array( $name => true ); ?> **/
    return keyValuePair( name, true );
  }

HTML_Attribute_Unquoted
  = name:HTML_Attribute_Name _* "=" _* value:$([a-zA-Z0-9]+)
  {
    /** <?php return array( $name => $value ); ?> **/
    return keyValuePair( name, value );
  }

HTML_Attribute_Quoted
  = name:HTML_Attribute_Name _* "=" _* '"' value:$(('\\"' . / !'"' .)*) '"'
  {
    /** <?php return array( $name => $value ); ?> **/
    return keyValuePair( name, value );
  }
  / name:HTML_Attribute_Name _* "=" _* "'" value:$(("\\'" . / !"'" .)*) "'"
  {
    /** <?php return array( $name => $value ); ?> **/
    return keyValuePair( name, value );
  }

HTML_Attribute_Name
  = $([a-zA-Z0-9:.]+)

ASCII_AlphaNumeric
  = ASCII_Letter
  / ASCII_Digit
  / Special_Chars

ASCII_Letter
  = [a-zA-Z]

ASCII_Digit
  = [0-9]

Special_Chars
  = [\-\_]

Newline
  = [\r\n]

_
  = [ \t]

__
  = _+

Any
  = .
