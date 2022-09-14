# typhoon-visualization

### 접근 방법

육지에 도착했을 때 힌남노 강도가 역대급이었다는데 얼마나 역대급이야? 

→ 힌남노 육지에 도착했을 때의 강도가 다른 태풍에 비교해 얼마나 강한 편일까?

살펴 볼 수 있는 지표 2가지: 풍속, 이동 속도

LANDFALL == 0 기준으로 힌남노와 태풍 강도 비교

지도 위에 동그라미 크기로 세기 나타내기, 위경도로 지도 위에 나타내는 방법 알아보기

### 결과물

![태풍 별 육지 위 최대 풍속(연대별).png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/4a6c0b9d-b542-41e7-8721-bf479f4d0a91/%ED%83%9C%ED%92%8D_%EB%B3%84_%EC%9C%A1%EC%A7%80_%EC%9C%84_%EC%B5%9C%EB%8C%80_%ED%92%8D%EC%86%8D(%EC%97%B0%EB%8C%80%EB%B3%84).png)

![태풍 별 육지 위 최대 이동 속도(연대별).png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/c155c878-15e0-493f-95da-cedf6538bbe6/%ED%83%9C%ED%92%8D_%EB%B3%84_%EC%9C%A1%EC%A7%80_%EC%9C%84_%EC%B5%9C%EB%8C%80_%EC%9D%B4%EB%8F%99_%EC%86%8D%EB%8F%84(%EC%97%B0%EB%8C%80%EB%B3%84).png)

![태풍 별 육지 위 최대 풍속(지도).png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/6604ad0b-e4e1-4052-8f51-59f165eb7fd6/%ED%83%9C%ED%92%8D_%EB%B3%84_%EC%9C%A1%EC%A7%80_%EC%9C%84_%EC%B5%9C%EB%8C%80_%ED%92%8D%EC%86%8D(%EC%A7%80%EB%8F%84).png)

![태풍 별 육지 위 최대 이동 속도(지도).png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/6c5a9b8b-a378-4024-abc4-f11aba6c8e7f/%ED%83%9C%ED%92%8D_%EB%B3%84_%EC%9C%A1%EC%A7%80_%EC%9C%84_%EC%B5%9C%EB%8C%80_%EC%9D%B4%EB%8F%99_%EC%86%8D%EB%8F%84(%EC%A7%80%EB%8F%84).png)

### 고민

- WMO_WIND, USA_WIND 중에 어떤 거 써서 태풍의 최대 풍속을 측정해야 하지..?
    - if NA fill with value from other column
    - Wind speed units are knots, but the averaging period can vary by source. → NA 값 있는 곳은 다른 source의 것으로 채우자
    - 그렇게 했는데도 NA가 있는 행은 제거하자
- 태풍 이동 속도 (감소 추세를 보여야)
- 태풍 최대 풍속 (증가 추세를 보여야)

### 

### 매번 마주하는 데이터 타입 문제

- 애초에 데이터를 불러 올 때 데이터 타입 주의, 특히 섞인 경우 없는지 확인
- 데이터 타입 문제 해결 방법 “parsing issues”
    - read_csv에서 따로 col_type 지정을 하거나
    - R file 탭 내에서 import로 데이터타입을 확인 해보자
    - 이번의 경우에는 첫번째 행에서 단위를 알려주는 바람에 오류가 났음
    - fread 쓰면 데이터타입 문제가 덜 발생한다고
