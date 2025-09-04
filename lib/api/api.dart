class API {
  static const hostConnect = "http://127.0.0.1/api_flutter";
  static const hostConnectUser = "$hostConnect/user";
  static const hostConnectAdmin = "$hostConnect/admin";
  static const hostConnectItems = "$hostConnect/items";
  static const hostClothes = "$hostConnect/clothes";
  static const hostCart = "$hostConnect/cart";
  static const hostFavorite = "$hostConnect/favorite";
  static const hostOrder = "$hostConnect/order";
  static const hostImages = "$hostConnect/transcation_image/";

  //user
  static const signUp = "$hostConnectUser/signup.php";
  static const login = "$hostConnectUser/login.php";
  static const validateEmail = "$hostConnectUser/validate_email.php";

  static const getTrendingPopuler = "$hostClothes/trending.php";
  static const getAllClothItems = "$hostClothes/all.php";

  static const getProduct = "$hostConnect/product.php";

  //Admin
  static const AdminLogin = "$hostConnectAdmin/login.php";
  static const AdminGetOrders = "$hostConnectAdmin/read_orders.php";

  //item
  static const uploadNewItem = "$hostConnectItems/upload.php";
  static const searchItem = "$hostConnectItems/search.php";

  //cart
  static const addToCart = "$hostCart/add.php";
  static const getCartList = "$hostCart/read.php";
  static const deleteSelectedItemFromCartList = "$hostCart/delete.php";
  static const updateQuantity = "$hostCart/update.php";

  //favorite
  static const addFavorite = "$hostFavorite/add.php";
  static const deleteFavorite = "$hostFavorite/delete.php";
  static const validateFavorite = "$hostFavorite/validate_favorite.php";
  static const readFavoriteList = "$hostFavorite/read.php";

  //order
  static const addOrder = "$hostOrder/add.php";
  static const readOrders = "$hostOrder/read.php";
  static const updateStatusOrders = "$hostOrder/update_status.php";
  static const readHistoryOrders = "$hostOrder/read_history.php";
}
