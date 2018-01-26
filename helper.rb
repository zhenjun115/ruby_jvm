require 'json'
require 'pp'

$CLASS_FILE = {
	"magic" => nil,
	"minor_version" => nil,
	"major_version" => nil,
	"constant_pool_count" => nil,
	"constant_pool" => [],
	"access_flags" => { "val" => nil, "means" => [] },
	"this_class" => nil,
	"super_class" => nil
}

def readU1( file )
	# 读取1个字节
	result = []
	result.push( file.getbyte() & 0xff )

	return result
end

def readU2( file )
	# 读取2个字节
	result = []
	1.upto( 2 ) {
		result.push( file.getbyte() & 0xff )
	}

	return result
end

def readU4( file )
	# 读取4个字节
	result = []
	1.upto( 4 ) {
		result.push( file.getbyte() & 0xff )
	}

	return result
end

def read_magic( file )
	result = readU4( file ).map { |item| item.to_s(16) }
	$CLASS_FILE[ 'magic' ] = result.join();
end

def read_minor_version( file )
	result = readU2( file ).map { |item| item.to_s(16) }
	$CLASS_FILE['minor_version'] = result.join().to_i( 16 )
end

def read_major_version( file )
	result = readU2( file ).map { |item| item.to_s(16) }
	$CLASS_FILE[ "major_version"] = result.join().to_i( 16 )
end

def read_constant_pool_count( file )
	result = readU2( file ).map { |item| item.to_s( 16 ) }
	$CLASS_FILE[ "constant_pool_count" ] = result.join().to_i( 16 )
end

############################
#
#cp_info
#
###########################

def read_tag( file ) # 读取tag
	result = readU1( file ).map{ |item| item.to_s( 16 ) }
	return result.join().to_i( 16 )
end

def read_CONSTANT_Methodref( file )
	result = { "tag" => 10, "class_index" => nil, "name_and_type_index" => nil }
	result[ "class_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	result[ "name_and_type_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	return result
end

def read_CONSTANT_Fieldref( file )
	result = { "tag" => 9, "class_index" => nil, "name_and_type_index" => nil }
	result[ "class_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	result[ "name_and_type_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	return result
end

def read_CONSTANT_String( file )
	result = { "tag" => 8, "string_index" => nil }
	result[ "string_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	return result
end

def read_CONSTANT_Class( file )
	result = { "tag" => 7, "name_index" => nil }
	result[ "name_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	return result
end

def read_CONSTANT_Utf8( file )
	result = { "tag" => 1, "length" => nil, "bytes" => [], 'utf-8' => nil }
	result[ "length" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	1.upto( result[ "length" ] ) {
		result[ 'bytes' ].push( file.getbyte() )
	}

	result[ 'utf-8' ] = result["bytes"].pack( "U*" )
	return result
end

def read_CONSTANT_NameAndType( file )
	result = { "tag" => 12, "name_index" => nil, "descriptor_index" => nil }
	result[ "name_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	result[ "descriptor_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	return result
end

def read_CONSTANT_InterfaceMethodref_info( file )
	result = { "tag" => 12,  "class_index" => nil, "name_and_type_index" => nil }
	result[ "class_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	result[ "name_and_type_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
end

def read_CONSTANT_Integer( file )
	result = { "tag" => 3, "bytes" => [] }
	1.upto( 4 ) {
		result[ 'bytes' ].push( file.getbyte() )
	}
	return result
end

def read_CONSTANT_Float( file )
	result = { "tag" => 4, "bytes" => [] }
	1.upto( 4 ) {
		result[ 'bytes' ].push( file.getbyte() )
	}
	return result
end

def read_CONSTANT_Long( file )
	result = { "tag" => 5, "high_bytes" => [], "low_bytes" => [] }
	1.upto( 4 ) {
		result[ 'high_bytes' ].push( file.getbyte() )
	}

	1.upto( 4 ) {
		result[ 'low_bytes' ].push( file.getbyte() )
	}
	return result
end


def read_CONSTANT_Double( file )
	result = { "tag" => 6, "high_bytes" => [], "low_bytes" => [] }
	1.upto( 4 ) {
		result[ 'high_bytes' ].push( file.getbyte() )
	}

	1.upto( 4 ) {
		result[ 'low_bytes' ].push( file.getbyte() )
	}
	return result
end

def read_CONSTANT_MethodType( file )
	result = { "tag" => 16, "descriptor_index" => nil }
	result[ "descriptor_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	return result
end

def read_CONSTANT_InvokeDynamic( file )
	result = { "tag" => 18, "bootstrap_method_attr_index" => nil, "name_and_type_index" => nil }
	result[ "bootstrap_method_attr_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	result[ "name_and_type_index" ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	return result
end

def read_cp_info( file )
	tag = read_tag( file )
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_Methodref( file ) ) if tag == 10
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_Fieldref( file ) ) if tag == 9 
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_String( file ) ) if tag == 8 
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_Class( file ) ) if tag == 7 
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_Utf8( file ) ) if tag == 1 
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_NameAndType( file ) ) if tag == 12 
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_InterfaceMethodref_info( file ) ) if tag == 11 
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_Integer( file ) ) if tag == 3
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_Float( file ) ) if tag == 4
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_Long( file ) ) if tag == 5
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_Double( file ) ) if tag == 6
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_MethodType( file ) ) if tag == 16
	$CLASS_FILE['constant_pool'].push( read_CONSTANT_InvokeDynamic( file ) ) if tag == 18
end

def read_constant_pool( file )
	1.upto( $CLASS_FILE['constant_pool_count'] - 1 ) { |i|
		read_cp_info( file )
	}
end

def read_access_flags( file )
	result = readU2( file )
	$CLASS_FILE[ 'access_flags' ][ 'val' ] = result.map { |item| item.to_s( 16 ) }.join().to_i( 16 )
	$CLASS_FILE[ 'access_flags' ]['means'].push( "ACC_PUBLIC" ) if result[ 1 ] & 0x0f == 1
	$CLASS_FILE[ 'access_flags' ]['means'].push( "ACC_FINAL" ) if result[ 1 ] >> 4 == 1
	$CLASS_FILE[ 'access_flags' ]['means'].push( "ACC_SUPER" ) if result[ 1 ] >> 4 == 2

	$CLASS_FILE[ 'access_flags' ]['means'].push( "ACC_INTERFACE" ) if result[ 0 ] & 0x0f == 2
	$CLASS_FILE[ 'access_flags' ]['means'].push( "ACC_ABSTRACT" ) if result[ 0 ] & 0x0f == 4

	$CLASS_FILE[ 'access_flags' ]['means'].push( "ACC_SYNTHETIC" ) if result[ 0 ] >> 4 == 1
	$CLASS_FILE[ 'access_flags' ]['means'].push( "ACC_ANNOTATION" ) if result[ 0 ] >> 4 == 2
	$CLASS_FILE[ 'access_flags' ]['means'].push( "ACC_ENUM" ) if result[ 0 ] >> 4 == 4
end

def read_this_class( file )
	this_class = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 ) 
	$CLASS_FILE[ 'this_class' ] = this_class
end

def read_super_class( file )
	super_class = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	$CLASS_FILE[ 'super_class' ] = super_class
end

def read_interfaces_count( file )
	interfaces_count = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	$CLASS_FILE[ 'interfaces_count' ] = interfaces_count
end

def read_interfaces( file )
	interfaces = []
	1.upto( $CLASS_FILE[ 'interfaces_count' ] ) { |i|
		interfaces.push( readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 ) )
	}

	$CLASS_FILE[ 'interfaces' ] = interfaces
end

def read_fields_count( file )
	fields_count = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	$CLASS_FILE[ 'fields_count' ] = fields_count
end

def read_fields( file )
	fields = []
	1.upto( $CLASS_FILE[ 'fields_count' ] ) { |item|
		#fields.push( readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 ) )
		#Todo, fields 信息读取
	}

	$CLASS_FILE[ 'fields' ] = fields
end

def read_methods_count( file )
	methods_count = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	$CLASS_FILE[ 'methods_count' ] = methods_count
end

def read_methods( file )
	methods = []
	1.upto( $CLASS_FILE[ 'methods_count' ] ) { |item|
		# methods.push( readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 ) )
		# method info
		method_info = {
			"access_flags" => nil,
			"name_index" => nil,
			"descriptor_index" => nil,
			"attributes_count" => nil,
			"attribute_info" => [] 
		}

		method_info[ 'access_flags' ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
		method_info[ 'name_index' ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
		method_info[ 'descriptor_index' ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
		method_info[ 'attributes_count' ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )

		1.upto( method_info[ 'attributes_count' ] ) { |item|
			attribute_info = {
				"attribute_name_index" => nil,
				"attribute_length" => nil,
				"info" => []
			}

			attribute_info[ 'attribute_name_index' ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
			attribute_info[ 'attribute_length' ] = readU4( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )

			1.upto( attribute_info[ 'attribute_length' ] ) {
				attribute_info[ 'info' ].push( readU1( file ) )
			}

			method_info[ 'attribute_info' ].push( attribute_info )
		}

		methods.push( method_info )
	}

	$CLASS_FILE[ 'methods' ] = methods
end

def read_attributes_count( file )
	attributes_count = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
	$CLASS_FILE[ 'attributes_count' ] = attributes_count
end

def read_attributes( file )
	attributes = []
	1.upto( $CLASS_FILE[ 'attributes_count' ] ) { |item|
		attribute_info = {
			"attribute_name_index" => nil,
			"attribute_length" => nil,
			"info" => []
		}

		attribute_info[ 'attribute_name_index' ] = readU2( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )
		attribute_info[ 'attribute_length' ] = readU4( file ).map{ |item| item.to_s( 16 ) }.join().to_i( 16 )

		1.upto( attribute_info[ 'attribute_length' ] ) {
			attribute_info[ 'info' ].push( readU1( file ) )
		}

		attributes.push( attribute_info )
	}

	$CLASS_FILE[ 'attributes' ] = attributes
end

def result()
	pp $CLASS_FILE
end
