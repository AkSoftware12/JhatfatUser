class ProductWithVarient{
  dynamic product_id;
  dynamic product_name;
  dynamic products_image;
  dynamic add_qnty;
  dynamic is_pres;
  dynamic is_id;
  dynamic isbasket;
  List<VarientList> data;
  dynamic selectPos;
  dynamic str1;
  dynamic str2;
  dynamic category_id;
  dynamic category_name;
  dynamic subcat_id;

  ProductWithVarient(
      this.product_id, this.product_name, this.products_image, this.add_qnty,this.is_pres,this.is_id,this.isbasket,this.data,this.selectPos,this.str1,this.str2,this.category_id,this.category_name,this.subcat_id);

  factory ProductWithVarient.fromJson(dynamic json){
    var tagObjsJson = json['data'] as List;
    List<VarientList> _tags = [];
    if(tagObjsJson!=null){
       _tags = tagObjsJson.map((tagJson) => VarientList.fromJson(tagJson)).toList();
    }
    return ProductWithVarient(json['product_id'], json['product_name'], json['products_image'], 0, json['is_pres'], json['is_id'],json['isbasket'],_tags,0,json['str1'],json['str2'],json['category_id'],json['category_name'],json["subcat_id"]);
  }

  @override
  String toString() {
    return 'ProductWithVarient{product_id: $product_id, product_name: $product_name, products_image: $products_image, add_qnty: $add_qnty,is_press: $is_pres,is_id: $is_id,isbasket:$isbasket ,data: $data, str1:$str1,str2:$str2,category_id:$category_id,category_name:$category_name}';
  }
}


class VarientList {

  dynamic varient_id;
  dynamic product_id;
  dynamic quantity;
  dynamic unit;
  dynamic strick_price;
  dynamic price;
  dynamic description;
  dynamic varient_image;
  dynamic vendor_id;
  dynamic stock;
  dynamic selected;
  dynamic add_qnty;

  VarientList(
      this.varient_id,
      this.product_id,
      this.quantity,
      this.unit,
      this.strick_price,
      this.price,
      this.description,
      this.varient_image,
      this.vendor_id,
      this.stock,
      this.selected,
      this.add_qnty);

  factory VarientList.fromJson(dynamic json){
    return VarientList(json['varient_id'], json['product_id'], json['quantity'], json['unit'], json['strick_price'], json['price'], json['description'], json['varient_image'], json['vendor_id'], json['stock'],false,0);
  }

  @override
  String toString() {
    return 'VarientList{varient_id: $varient_id, product_id: $product_id, quantity: $quantity, unit: $unit, strick_price: $strick_price, price: $price, description: $description, varient_image: $varient_image, vendor_id: $vendor_id, stock: $stock}';
  }
}