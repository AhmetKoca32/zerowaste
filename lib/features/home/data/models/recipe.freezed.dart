// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Recipe {
  String get id => throw _privateConstructorUsedError;

  /// Turkish title (canonical / sort key).
  String get title => throw _privateConstructorUsedError;

  /// English title — required for curated Firestore recipes.
  String get titleEn => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get descriptionEn => throw _privateConstructorUsedError;
  List<String> get instructions => throw _privateConstructorUsedError;
  List<String> get instructionsEn => throw _privateConstructorUsedError;
  List<String> get ingredients => throw _privateConstructorUsedError;
  List<String> get ingredientsEn => throw _privateConstructorUsedError;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeCopyWith<Recipe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeCopyWith<$Res> {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) then) =
      _$RecipeCopyWithImpl<$Res, Recipe>;
  @useResult
  $Res call({
    String id,
    String title,
    String titleEn,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? description,
    String? descriptionEn,
    List<String> instructions,
    List<String> instructionsEn,
    List<String> ingredients,
    List<String> ingredientsEn,
  });
}

/// @nodoc
class _$RecipeCopyWithImpl<$Res, $Val extends Recipe>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? titleEn = null,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? descriptionEn = freezed,
    Object? instructions = null,
    Object? instructionsEn = null,
    Object? ingredients = null,
    Object? ingredientsEn = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            titleEn: null == titleEn
                ? _value.titleEn
                : titleEn // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            descriptionEn: freezed == descriptionEn
                ? _value.descriptionEn
                : descriptionEn // ignore: cast_nullable_to_non_nullable
                      as String?,
            instructions: null == instructions
                ? _value.instructions
                : instructions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            instructionsEn: null == instructionsEn
                ? _value.instructionsEn
                : instructionsEn // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            ingredients: null == ingredients
                ? _value.ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            ingredientsEn: null == ingredientsEn
                ? _value.ingredientsEn
                : ingredientsEn // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeImplCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$$RecipeImplCopyWith(
    _$RecipeImpl value,
    $Res Function(_$RecipeImpl) then,
  ) = __$$RecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String titleEn,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? description,
    String? descriptionEn,
    List<String> instructions,
    List<String> instructionsEn,
    List<String> ingredients,
    List<String> ingredientsEn,
  });
}

/// @nodoc
class __$$RecipeImplCopyWithImpl<$Res>
    extends _$RecipeCopyWithImpl<$Res, _$RecipeImpl>
    implements _$$RecipeImplCopyWith<$Res> {
  __$$RecipeImplCopyWithImpl(
    _$RecipeImpl _value,
    $Res Function(_$RecipeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? titleEn = null,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? descriptionEn = freezed,
    Object? instructions = null,
    Object? instructionsEn = null,
    Object? ingredients = null,
    Object? ingredientsEn = null,
  }) {
    return _then(
      _$RecipeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        titleEn: null == titleEn
            ? _value.titleEn
            : titleEn // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        descriptionEn: freezed == descriptionEn
            ? _value.descriptionEn
            : descriptionEn // ignore: cast_nullable_to_non_nullable
                  as String?,
        instructions: null == instructions
            ? _value._instructions
            : instructions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        instructionsEn: null == instructionsEn
            ? _value._instructionsEn
            : instructionsEn // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        ingredients: null == ingredients
            ? _value._ingredients
            : ingredients // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        ingredientsEn: null == ingredientsEn
            ? _value._ingredientsEn
            : ingredientsEn // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$RecipeImpl extends _Recipe {
  const _$RecipeImpl({
    required this.id,
    required this.title,
    this.titleEn = '',
    @JsonKey(name: 'image_url') this.imageUrl,
    this.description,
    this.descriptionEn,
    required final List<String> instructions,
    final List<String> instructionsEn = const [],
    required final List<String> ingredients,
    final List<String> ingredientsEn = const [],
  }) : _instructions = instructions,
       _instructionsEn = instructionsEn,
       _ingredients = ingredients,
       _ingredientsEn = ingredientsEn,
       super._();

  @override
  final String id;

  /// Turkish title (canonical / sort key).
  @override
  final String title;

  /// English title — required for curated Firestore recipes.
  @override
  @JsonKey()
  final String titleEn;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  final String? description;
  @override
  final String? descriptionEn;
  final List<String> _instructions;
  @override
  List<String> get instructions {
    if (_instructions is EqualUnmodifiableListView) return _instructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_instructions);
  }

  final List<String> _instructionsEn;
  @override
  @JsonKey()
  List<String> get instructionsEn {
    if (_instructionsEn is EqualUnmodifiableListView) return _instructionsEn;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_instructionsEn);
  }

  final List<String> _ingredients;
  @override
  List<String> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  final List<String> _ingredientsEn;
  @override
  @JsonKey()
  List<String> get ingredientsEn {
    if (_ingredientsEn is EqualUnmodifiableListView) return _ingredientsEn;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredientsEn);
  }

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, titleEn: $titleEn, imageUrl: $imageUrl, description: $description, descriptionEn: $descriptionEn, instructions: $instructions, instructionsEn: $instructionsEn, ingredients: $ingredients, ingredientsEn: $ingredientsEn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.titleEn, titleEn) || other.titleEn == titleEn) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.descriptionEn, descriptionEn) ||
                other.descriptionEn == descriptionEn) &&
            const DeepCollectionEquality().equals(
              other._instructions,
              _instructions,
            ) &&
            const DeepCollectionEquality().equals(
              other._instructionsEn,
              _instructionsEn,
            ) &&
            const DeepCollectionEquality().equals(
              other._ingredients,
              _ingredients,
            ) &&
            const DeepCollectionEquality().equals(
              other._ingredientsEn,
              _ingredientsEn,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    titleEn,
    imageUrl,
    description,
    descriptionEn,
    const DeepCollectionEquality().hash(_instructions),
    const DeepCollectionEquality().hash(_instructionsEn),
    const DeepCollectionEquality().hash(_ingredients),
    const DeepCollectionEquality().hash(_ingredientsEn),
  );

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      __$$RecipeImplCopyWithImpl<_$RecipeImpl>(this, _$identity);
}

abstract class _Recipe extends Recipe {
  const factory _Recipe({
    required final String id,
    required final String title,
    final String titleEn,
    @JsonKey(name: 'image_url') final String? imageUrl,
    final String? description,
    final String? descriptionEn,
    required final List<String> instructions,
    final List<String> instructionsEn,
    required final List<String> ingredients,
    final List<String> ingredientsEn,
  }) = _$RecipeImpl;
  const _Recipe._() : super._();

  @override
  String get id;

  /// Turkish title (canonical / sort key).
  @override
  String get title;

  /// English title — required for curated Firestore recipes.
  @override
  String get titleEn;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  String? get description;
  @override
  String? get descriptionEn;
  @override
  List<String> get instructions;
  @override
  List<String> get instructionsEn;
  @override
  List<String> get ingredients;
  @override
  List<String> get ingredientsEn;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
