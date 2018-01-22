require 'json'

$CLASS_FILE = {
	"magic" => nil,
	"minor_version" => nil,
	"major_version" => nil,
	"constant_pool_count" => nil,
	"constant_pool" => [],
	"access_flags" => nil,
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
	result = readU2( file ).map { |item| item.to_s(16) }
	$CLASS_FILE['minor_version'] = result.join().to_i( 16 )
end

def result()
	puts $CLASS_FILE
end
