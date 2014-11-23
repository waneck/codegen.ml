package data;

abstract Tag(String) from String to String
{
	static var regex = ~/([^A-Za-z0-9_\-]+)/g;

	public var name(get,never):String;
	public var normalized(get,never):String;

	inline public function new(name:String)
	{
		this = name;
	}

	inline private function get_name()
	{
		return this;
	}

	inline private function get_normalized()
	{
		return regex.replace(name,"_");
	}

	public function getAddress()
	{
		return '/tags/$normalized.html';
	}
}
