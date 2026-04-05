from setuptools import setup, find_packages

install_requires = [
    'fastapi==0.115.0',
    'uvicorn==0.30.6',
    'pydantic==2.8.2',
    'kafka-python==2.0.2',
    'python-dotenv==1.0.1'
]

setup(
    name='ds-service',
    version='1.0',
    packages=find_packages('src'),
    package_dir={'': 'src'},
    install_requires=install_requires,
    include_package_data=True,
)