'use client';

import Image from "next/image";
import { useState } from 'react';
import ImageUploader from '@/components/ImageUploader';

export default function Home() {
  const [menuImage1, setMenuImage1] = useState('/menu-image-1.pdf');
  const [menuImage2, setMenuImage2] = useState('/menu-image-2.pdf');

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-50">
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-md border-b border-blue-100 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-3">
              <div className="w-12 h-12">
                <Image
                  src="/Logo.svg"
                  alt="밥묵자 로고"
                  width={48}
                  height={48}
                  className="w-full h-full"
                />
              </div>
              <span className="text-2xl font-bold text-gray-800">밥묵자</span>
            </div>
            <div className="hidden md:flex space-x-8">
              <a href="#features" className="text-gray-600 hover:text-blue-600 transition-colors">기능</a>
              <a href="#widget" className="text-gray-600 hover:text-blue-600 transition-colors">위젯</a>
              <a href="#download" className="text-gray-600 hover:text-blue-600 transition-colors">다운로드</a>
            </div>
            <button className="bg-gradient-to-r from-blue-500 to-indigo-500 text-white px-6 py-2 rounded-full hover:shadow-lg transition-all duration-300">
              앱 다운로드
            </button>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-20 pb-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-7xl mx-auto">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <div className="space-y-8">
              <div className="space-y-4">
                <h1 className="text-5xl lg:text-6xl font-bold text-gray-900 leading-tight">
                  학교 식당을
                  <span className="bg-gradient-to-r from-blue-500 to-indigo-500 bg-clip-text text-transparent"> 한눈에</span>
                </h1>
                <p className="text-xl text-gray-600 leading-relaxed">
                  선택한 학교의 학식, 긱식, 교식을 실시간으로 비교하고<br />
                  가장 맛있는 메뉴를 찾아보세요
                </p>
              </div>
              
              <div className="flex flex-col sm:flex-row gap-4">
                <button className="bg-gradient-to-r from-blue-500 to-indigo-500 text-white px-8 py-4 rounded-full text-lg font-semibold hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1">
                  App Store에서 다운로드
                </button>
                <button className="border-2 border-blue-500 text-blue-500 px-8 py-4 rounded-full text-lg font-semibold hover:bg-blue-500 hover:text-white transition-all duration-300">
                  더 알아보기
                </button>
              </div>

              <div className="flex items-center space-x-6 text-sm text-gray-500">
                <div className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <span>실시간 메뉴</span>
                </div>
                <div className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                  <span>위젯 지원</span>
                </div>
                <div className="flex items-center space-x-2">
                  <div className="w-2 h-2 bg-purple-500 rounded-full"></div>
                  <span>무료 사용</span>
                </div>
              </div>
            </div>

            <div className="relative flex justify-center">
              <div className="relative z-10 ml-8">
                <div className="bg-white rounded-3xl shadow-2xl p-3 transform rotate-3 hover:rotate-0 transition-transform duration-500 w-fit">
                  <Image
                    src="/3rdscreen.svg"
                    alt="밥묵자 앱 화면"
                    width={200}
                    height={600}
                    className="w-full h-auto max-w-[200px]"
                    quality={100}
                    priority
                  />
                </div>
              </div>
              
              {/* Background decoration */}
              <div className="absolute -top-4 -right-4 w-72 h-72 bg-gradient-to-r from-blue-200 to-indigo-200 rounded-full opacity-20 blur-3xl"></div>
              <div className="absolute -bottom-8 -left-8 w-64 h-64 bg-gradient-to-r from-cyan-200 to-blue-200 rounded-full opacity-20 blur-3xl"></div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">왜 밥묵자일까요?</h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              여러 식당의 메뉴를 한 번에 비교하고, 가장 맛있고 저렴한 선택을 하세요
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center p-8 rounded-2xl hover:shadow-lg transition-shadow duration-300">
              <div className="w-16 h-16 bg-gradient-to-r from-blue-500 to-indigo-500 rounded-2xl flex items-center justify-center mx-auto mb-6">
                <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">실시간 비교</h3>
              <p className="text-gray-600">
                학식, 긱식, 교식의 메뉴와 가격을 실시간으로 비교하여 가장 좋은 선택을 할 수 있습니다
              </p>
            </div>

            <div className="text-center p-8 rounded-2xl hover:shadow-lg transition-shadow duration-300">
              <div className="w-16 h-16 bg-gradient-to-r from-blue-500 to-indigo-500 rounded-2xl flex items-center justify-center mx-auto mb-6">
                <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z" />
                </svg>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">간편한 사용</h3>
              <p className="text-gray-600">
                직관적인 인터페이스로 누구나 쉽게 사용할 수 있으며, 빠르게 원하는 정보를 찾을 수 있습니다
              </p>
            </div>

            <div className="text-center p-8 rounded-2xl hover:shadow-lg transition-shadow duration-300">
              <div className="w-16 h-16 bg-gradient-to-r from-cyan-500 to-blue-500 rounded-2xl flex items-center justify-center mx-auto mb-6">
                <svg className="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                </svg>
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">학생 친화적</h3>
              <p className="text-gray-600">
                학생들의 실제 니즈를 반영하여 개발된 앱으로, 학식 정보를 가장 효율적으로 제공합니다
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Widget Section */}
      <section id="widget" className="py-20 bg-gradient-to-r from-blue-50 to-indigo-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <div className="space-y-8">
              <div className="space-y-4">
                <h2 className="text-4xl font-bold text-gray-900">홈 화면 위젯</h2>
                <p className="text-xl text-gray-600">
                  앱을 열지 않고도 홈 화면에서 바로 오늘의 메뉴를 확인하세요
                </p>
              </div>

              <div className="space-y-6">
                <div className="flex items-start space-x-4">
                  <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                    <svg className="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">실시간 메뉴 표시</h3>
                    <p className="text-gray-600">위젯에서 현재 시간대의 메뉴를 바로 확인할 수 있습니다</p>
                  </div>
                </div>

                <div className="flex items-start space-x-4">
                  <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                    <svg className="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">다양한 크기 지원</h3>
                    <p className="text-gray-600">작은 위젯부터 큰 위젯까지 원하는 크기로 설정할 수 있습니다</p>
                  </div>
                </div>

                <div className="flex items-start space-x-4">
                  <div className="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0 mt-1">
                    <svg className="w-4 h-4 text-white" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">자동 업데이트</h3>
                    <p className="text-gray-600">메뉴가 변경되면 위젯도 자동으로 업데이트됩니다</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="relative">
              <div className="bg-white rounded-3xl shadow-2xl p-4 max-w-sm mx-auto w-fit">
                <Image
                  src="/wiget.svg"
                  alt="밥묵자 위젯"
                  width={300}
                  height={400}
                  className="w-full h-auto"
                  quality={100}
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Download Section */}
      <section id="download" className="py-20 bg-gray-900">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <div className="space-y-8">
            <div className="space-y-4">
              <h2 className="text-4xl font-bold text-white">지금 다운로드하세요</h2>
              <p className="text-xl text-gray-300 max-w-2xl mx-auto">
                iOS App Store에서 밥묵자를 다운로드하고 더 이상 식당 선택에 고민하지 마세요
              </p>
            </div>

            <div className="flex flex-col sm:flex-row gap-6 justify-center items-center">
              <button className="bg-white text-gray-900 px-8 py-4 rounded-2xl text-lg font-semibold hover:bg-gray-100 transition-colors duration-300 flex items-center space-x-3">
                <svg className="w-8 h-8" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                </svg>
                <div className="text-left">
                  <div className="text-xs">Download on the</div>
                  <div className="text-lg font-semibold">App Store</div>
                </div>
              </button>

              <div className="text-gray-400 text-sm">
                <p>iOS 15.0 이상 필요</p>
                <p>무료 다운로드</p>
              </div>
            </div>


          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-800 py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid md:grid-cols-4 gap-8">
            <div className="space-y-4">
              <div className="flex items-center space-x-3">
                <div className="w-12 h-12">
                  <Image
                    src="/Logo.svg"
                    alt="밥묵자 로고"
                    width={48}
                    height={48}
                    className="w-full h-full"
                  />
                </div>
                <span className="text-2xl font-bold text-white">밥묵자</span>
              </div>
              <p className="text-gray-400">
                학교 식당 메뉴를 한눈에 비교하는 iOS 앱
              </p>
            </div>

            <div>
              <h3 className="text-white font-semibold mb-4">앱</h3>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white transition-colors">기능</a></li>
                <li><a href="#" className="hover:text-white transition-colors">위젯</a></li>
                <li><a href="#" className="hover:text-white transition-colors">다운로드</a></li>
              </ul>
            </div>

            <div>
              <h3 className="text-white font-semibold mb-4">지원</h3>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white transition-colors">도움말</a></li>
                <li><a href="#" className="hover:text-white transition-colors">문의하기</a></li>
                <li><a href="#" className="hover:text-white transition-colors">학교 추가 요청</a></li>
              </ul>
            </div>

            <div>
              <h3 className="text-white font-semibold mb-4">연락처</h3>
              <ul className="space-y-2 text-gray-400">
                <li>songsy0612@gmail.com</li>
              </ul>
            </div>
          </div>

          <div className="border-t border-gray-700 mt-8 pt-8 text-center text-gray-400">
            <p>&copy; 2024 밥묵자. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}