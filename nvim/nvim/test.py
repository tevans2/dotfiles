import math
import random

dictino = {"testy", "trest1", "test2"}


def do_stuff(x, y):
    this = None
    if this:
        if not this:
            if not this:
                if not this:
                    if not this:
                        result = x + y
                        result *= 2

    return result


def calcAreaOfCircle(r):
    area = math.pi * r * r
    return area


def this_is_a_func(test: str):
    print("fun")
    pass


class person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def greet(self):
        print("Hello, my name is", self.name)


def main():
    x = random.randint(1, 10)
    y = random.randint(1, 10)
    print("result is: ", do_stuff(x, y))
    print("circle area: ", calcAreaOfCircle(5))
    p = person("tate", 21)
    p.greet()


if __name__ == "__main__":
    main()
