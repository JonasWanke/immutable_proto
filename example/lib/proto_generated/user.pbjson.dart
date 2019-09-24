///
//  Generated code. Do not modify.
//  source: user.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const User$json = const {
  '1': 'User',
  '2': const [
    const {'1': 'first_name', '3': 1, '4': 1, '5': 9, '10': 'firstName'},
    const {'1': 'last_name', '3': 2, '4': 1, '5': 9, '10': 'lastName'},
    const {'1': 'email_addresses', '3': 3, '4': 3, '5': 11, '6': '.wanke.immutable_proto.example.User.EmailAddress', '10': 'emailAddresses'},
    const {'1': 'favorite_drinks', '3': 4, '4': 3, '5': 14, '6': '.wanke.immutable_proto.example.User.FavoriteDrink', '10': 'favoriteDrinks'},
  ],
  '3': const [User_EmailAddress$json],
  '4': const [User_FavoriteDrink$json],
};

const User_EmailAddress$json = const {
  '1': 'EmailAddress',
  '2': const [
    const {'1': 'local_part', '3': 1, '4': 1, '5': 9, '10': 'localPart'},
    const {'1': 'domain', '3': 2, '4': 1, '5': 9, '10': 'domain'},
  ],
};

const User_FavoriteDrink$json = const {
  '1': 'FavoriteDrink',
  '2': const [
    const {'1': 'UNKNOWN', '2': 0},
    const {'1': 'COFFEE', '2': 1},
    const {'1': 'COKE', '2': 2},
    const {'1': 'TEA', '2': 3},
  ],
};

